import Foundation
import SwiftUI
import UIKit
import AltSign

enum SigningPhase: String {
    case idle
    case anisette
    case authenticating
    case twoFactor
    case teams
    case device
    case certificate
    case appID
    case profile
    case ready
    case failed
}

final class SigningEngine: ObservableObject {

    static let shared = SigningEngine()

    @Published var phase: SigningPhase = .idle
    @Published var status: String = ""
    @Published var needsCode: Bool = false
    @Published var teams: [ALTTeam] = []
    @Published var selectedTeam: ALTTeam?
    @Published var certificateName: String = ""
    @Published var appIDCount: Int = 0
    @Published var lastError: String?
    @Published var sessionEmail: String = ""

    private var account: ALTAccount?
    private var session: ALTAppleAPISession?
    private var twoFactorCompletion: ((String?) -> Void)?
    private var certificate: ALTCertificate?
    private var appID: ALTAppID?
    private var provisioningProfile: ALTProvisioningProfile?
    private var didSignIn = false

    private init() {}

    // MARK: 工具

    private func set(_ phase: SigningPhase, _ text: String) {
        DispatchQueue.main.async {
            self.phase = phase
            self.status = text
        }
    }

    private func fail(_ text: String) {
        DispatchQueue.main.async {
            self.phase = .failed
            self.status = text
            self.lastError = text
        }
    }

    var deviceUDID: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

    var deviceType: ALTDeviceType {
        UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    }

    // MARK: anisette

    func makeAnisette() -> ALTAnisetteData? {
        guard let fields = KOPLocalAnisette() else { return nil }
        let machineID = fields["machineID"] as? String ?? ""
        let otp = fields["oneTimePassword"] as? String ?? ""
        let localUser = fields["localUserID"] as? String ?? ""
        let routing = fields["routingInfo"] as? NSNumber ?? NSNumber(value: 0)

        guard !machineID.isEmpty, !otp.isEmpty else { return nil }

        return ALTAnisetteData(
            machineID: machineID,
            oneTimePassword: otp,
            localUserID: localUser,
            routingInfo: routing.uint64Value,
            deviceUniqueIdentifier: UUID().uuidString,
            deviceSerialNumber: "0",
            deviceDescription: UIDevice.current.model,
            date: Date(),
            locale: Locale(identifier: "zh_CN"),
            timeZone: TimeZone.current
        )
    }

    // MARK: 登录

    func signIn(appleID: String, password: String) {
        set(.anisette, L("正在用本机生成设备指纹…", "Generating device fingerprint…"))

        guard let anisette = makeAnisette() else {
            fail(L("本机 AOSKit 不可用，请在「我的」里切换服务器模式",
                   "Local AOSKit unavailable, switch server mode in Me"))
            return
        }

        set(.authenticating, L("正在登录 Apple ID…", "Signing in to Apple ID…"))

        ALTAppleAPI.shared.authenticate(
            appleID: appleID,
            password: password,
            anisetteData: anisette,
            xcodeVersion: "16.0",
            verificationHandler: { completion in
                DispatchQueue.main.async {
                    self.twoFactorCompletion = completion
                    self.needsCode = true
                    self.phase = .twoFactor
                    self.status = L("Apple 已发送六位验证码", "Apple sent a 6-digit code")
                }
            },
            completionHandler: { account, session, error in
                if let error = error {
                    self.fail(error.localizedDescription)
                    return
                }
                guard let account = account, let session = session else {
                    self.fail(L("登录没有拿到会话", "No session returned"))
                    return
                }
                self.account = account
                self.session = session
                self.didSignIn = true
                DispatchQueue.main.async {
                    self.sessionEmail = appleID
                    self.needsCode = false
                }
                self.loadTeams()
            }
        )
    }

    func submitCode(_ code: String) {
        guard let completion = twoFactorCompletion else { return }
        needsCode = false
        twoFactorCompletion = nil
        set(.authenticating, L("正在校验验证码…", "Verifying code…"))
        completion(code)
    }

    // MARK: 团队

    private func loadTeams() {
        guard let account = account, let session = session else { return }
        set(.teams, L("正在读取开发者团队…", "Loading teams…"))

        ALTAppleAPI.shared.fetchTeams(for: account, session: session) { teams, error in
            if let error = error {
                self.fail(error.localizedDescription)
                return
            }
            guard let teams = teams, !teams.isEmpty else {
                self.fail(L("这个账户没有可用的免费团队", "No free team on this account"))
                return
            }
            DispatchQueue.main.async {
                self.teams = teams
                self.selectedTeam = teams.first
            }
            self.registerDevice()
        }
    }

    // MARK: 设备

    private func registerDevice() {
        guard let team = selectedTeam, let session = session else { return }
        set(.device, L("正在登记这台设备…", "Registering this device…"))

        ALTAppleAPI.shared.registerDevice(
            name: UIDevice.current.name,
            identifier: deviceUDID,
            type: deviceType,
            team: team,
            session: session
        ) { device, error in
            if let error = error {
                self.fail(error.localizedDescription)
                return
            }
            guard device != nil else {
                self.fail(L("设备登记没有返回结果", "Device registration returned nothing"))
                return
            }
            self.requestCertificate()
        }
    }

    // MARK: 证书

    private func requestCertificate() {
        guard let team = selectedTeam, let session = session else { return }
        set(.certificate, L("正在申请签名证书…", "Requesting certificate…"))

        ALTAppleAPI.shared.addCertificate(machineName: "App KOP LOP", to: team, session: session) { certificate, error in
            if let error = error {
                self.fail(error.localizedDescription)
                return
            }
            guard let certificate = certificate else {
                self.fail(L("证书申请没有返回结果", "Certificate request returned nothing"))
                return
            }
            self.certificate = certificate
            DispatchQueue.main.async { self.certificateName = certificate.name }
            self.requestAppID()
        }
    }

    // MARK: App ID

    func requestAppID(bundleIdentifier: String = "com.hjm98.appkoplop.extra") {
        guard let team = selectedTeam, let session = session else { return }
        set(.appID, L("正在申请 App ID…", "Requesting App ID…"))

        ALTAppleAPI.shared.fetchAppIDs(for: team, session: session) { existing, error in
            if let error = error {
                self.fail(error.localizedDescription)
                return
            }
            DispatchQueue.main.async { self.appIDCount = existing?.count ?? 0 }

            if let match = existing?.first(where: { $0.bundleIdentifier == bundleIdentifier }) {
                self.appID = match
                self.loadProfile(bundleIdentifier: bundleIdentifier)
                return
            }

            ALTAppleAPI.shared.addAppID(
                withName: "App KOP LOP",
                bundleIdentifier: bundleIdentifier,
                team: team,
                session: session
            ) { appID, error in
                if let error = error {
                    self.fail(error.localizedDescription)
                    return
                }
                guard let appID = appID else {
                    self.fail(L("App ID 没有返回结果", "No App ID returned"))
                    return
                }
                self.appID = appID
                self.loadProfile(bundleIdentifier: bundleIdentifier)
            }
        }
    }

    // MARK: 描述文件

    private func loadProfile(bundleIdentifier: String) {
        guard let team = selectedTeam, let session = session, let appID = appID else { return }
        set(.profile, L("正在生成描述文件…", "Generating provisioning profile…"))

        ALTAppleAPI.shared.fetchProvisioningProfile(
            for: appID,
            deviceType: deviceType,
            team: team,
            session: session
        ) { profile, error in
            if let error = error {
                self.fail(error.localizedDescription)
                return
            }
            guard let profile = profile else {
                self.fail(L("描述文件没有返回结果", "No provisioning profile returned"))
                return
            }
            self.provisioningProfile = profile
            DispatchQueue.main.async {
                self.phase = .ready
                self.status = L("签名环境已就绪，可以签名安装", "Signing environment ready")
            }
        }
    }

    // MARK: 签名

    func sign(appAt url: URL, completion: ((URL?) -> Void)? = nil) {
        guard let team = selectedTeam, let certificate = certificate, let profile = provisioningProfile else {
            fail(L("签名环境还没准备好", "Signing environment not ready"))
            completion?(nil)
            return
        }
        set(.ready, L("正在签名…", "Signing…"))

        let signer = ALTSigner(team: team, certificate: certificate)
        _ = signer.signApp(at: url, provisioningProfiles: [profile]) { success, error in
            if let error = error {
                self.fail(error.localizedDescription)
                completion?(nil)
                return
            }
            DispatchQueue.main.async {
                self.phase = .ready
                self.status = success ? L("签名完成", "Signed") : L("签名失败", "Signing failed")
            }
            completion?(success ? url : nil)
        }
    }

    func reset() {
        phase = .idle
        status = ""
        needsCode = false
        lastError = nil
        teams = []
        selectedTeam = nil
        certificate = nil
        appID = nil
        provisioningProfile = nil
        twoFactorCompletion = nil
        account = nil
        session = nil
    }
}
