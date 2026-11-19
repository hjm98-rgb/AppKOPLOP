import SwiftUI

// MARK: - 我的

struct MeView: View {
    @EnvironmentObject var engine: StoreEngine
    @EnvironmentObject var signing: SigningEngine

    @State private var showAddAccount = false
    @State private var showSigning = false
    @State private var showServerSheet = false
    @State private var showPrivacy = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                accountCard
                serviceCard
                accountsCard
                prefCard
                aboutCard
                footer
            }
            .padding(.bottom, 34)
        }
        .sheet(isPresented: $showAddAccount) {
            AddAccountSheet { alias, id in
                engine.addAccount(alias: alias, appleID: id)
            }
        }
        .sheet(isPresented: $showServerSheet) {
            ServerSheet()
                .environmentObject(engine)
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyShortSheet()
        }
        .sheet(isPresented: $showSigning) {
            SigningSetupView()
                .environmentObject(signing)
                .environmentObject(engine)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L("我的", "Me"))
                .font(DS.title(32))
                .foregroundColor(DS.ink)
            Text(L("账号、签名与本地通道", "Account, signing and local channel"))
                .font(DS.text(14))
                .foregroundColor(DS.sub)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    // MARK: 账户

    private var accountCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(DS.fill)
                Text(engine.appleIDLinked ? "A" : "?")
                    .font(DS.text(20, .bold))
                    .foregroundColor(DS.ink)
            }
            .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 3) {
                Text(engine.appleIDLinked ? engine.appleIDMasked : L("未连接 Apple 账户", "No Apple account connected"))
                    .font(DS.text(16, .semibold))
                    .foregroundColor(DS.ink)
                Text(engine.appleIDLinked
                     ? L("用于签名，凭据存于本机", "Used for signing, stored locally")
                     : L("跳过也可以，随时在下面添加", "Skipped? Add one below anytime"))
                    .font(DS.text(12))
                    .foregroundColor(DS.sub)
            }
            Spacer(minLength: 0)

            Button {
                showAddAccount = true
            } label: {
                Text(engine.appleIDLinked ? L("管理", "Manage") : L("连接", "Connect"))
                    .font(DS.text(13, .semibold))
                    .foregroundColor(DS.blue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(DS.canvas))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(DS.group))
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: 服务

    private var serviceCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L("签名服务", "Signing"))

            VStack(spacing: 0) {
                Button { showServerSheet = true } label: {
                    HStack(spacing: 12) {
                        iconBox("antenna.radiowaves.left.and.right")
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L("Anisette 服务器", "Anisette server"))
                                .font(DS.text(15, .medium))
                                .foregroundColor(DS.ink)
                            Text(L("登录 Apple 账户时使用的设备指纹来源", "Device fingerprint source for Apple sign-in"))
                                .font(DS.text(11))
                                .foregroundColor(DS.sub)
                        }
                        Spacer(minLength: 4)
                        Text(engine.serverLabel)
                            .font(DS.text(13, .medium))
                            .foregroundColor(DS.blue)
                            .multilineTextAlignment(.trailing)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DS.sub.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                .buttonStyle(.plain)

                HDivider().padding(.leading, 56)

                HStack(spacing: 12) {
                    iconBox("arrow.triangle.2.circlepath")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("VPN 本地循环通道", "Local loopback channel"))
                            .font(DS.text(15, .medium))
                            .foregroundColor(DS.ink)
                        Text(engine.vpnConnected
                             ? L("已连接 · 安装请求走本机地址", "Connected · installs go to localhost")
                             : L("未连接 · 安装时自动开启", "Not connected · starts on install"))
                            .font(DS.text(11))
                            .foregroundColor(engine.vpnConnected ? DS.green : DS.sub)
                    }
                    Spacer(minLength: 4)
                    Circle()
                        .fill(engine.vpnConnected ? DS.green : DS.line)
                        .frame(width: 8, height: 8)
                    Toggle("", isOn: Binding(
                        get: { engine.vpnConnected },
                        set: { _ in engine.toggleVPN() }
                    ))
                    .labelsHidden()
                    .tint(DS.blue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)

                HDivider().padding(.leading, 56)

                Button { showSigning = true } label: {
                    HStack(spacing: 12) {
                        iconBox("key.fill")
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L("签名环境", "Signing environment"))
                                .font(DS.text(15, .medium))
                                .foregroundColor(DS.ink)
                            Text(signingStatusText)
                                .font(DS.text(11))
                                .foregroundColor(signing.phase == .ready ? DS.green : DS.sub)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DS.sub.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                .buttonStyle(.plain)

                HDivider().padding(.leading, 56)

                HStack(spacing: 12) {
                    iconBox("number.square")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("剩余 App ID", "App IDs left"))
                            .font(DS.text(15, .medium))
                            .foregroundColor(DS.ink)
                        Text(L("免费证书每 7 天可签 \(engine.appIDQuota) 个", "Free certificate allows \(engine.appIDQuota) per 7 days"))
                            .font(DS.text(11))
                            .foregroundColor(DS.sub)
                    }
                    Spacer(minLength: 4)
                    Text("\(engine.appIDsLeft) / \(engine.appIDQuota)")
                        .font(DS.text(17, .bold))
                        .foregroundColor(engine.appIDsLeft > 0 ? DS.ink : Color(hex: "#C0392B"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)

                HDivider().padding(.leading, 56)

                HStack(spacing: 12) {
                    iconBox("checkmark.seal")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("可签名的 Apple 账户", "Signing accounts"))
                            .font(DS.text(15, .medium))
                            .foregroundColor(DS.ink)
                        Text(L("已添加 \(engine.signedAccountCount) 个", "\(engine.signedAccountCount) added"))
                            .font(DS.text(11))
                            .foregroundColor(DS.sub)
                    }
                    Spacer(minLength: 4)
                    Text("\(engine.signedAccountCount)")
                        .font(DS.text(17, .bold))
                        .foregroundColor(DS.ink)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
            .padding(.horizontal, 20)
        }
    }

    private var signingStatusText: String {
        switch signing.phase {
        case .ready: return L("已就绪 · 可签名", "Ready to sign")
        case .idle: return L("未配置 · 点此登录", "Not set up · tap to sign in")
        case .twoFactor: return L("等待六位验证码", "Waiting for the 6-digit code")
        case .failed: return L("配置失败 · 点此重试", "Failed · tap to retry")
        default: return signing.status.isEmpty ? L("配置中…", "Setting up…") : signing.status
        }
    }

    private func iconBox(_ name: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(DS.canvas)
            Image(systemName: name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(DS.blue)
        }
        .frame(width: 32, height: 32)
    }

    // MARK: 账户列表

    private var accountsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L("签名账户", "Accounts"))

            VStack(spacing: 0) {
                if engine.accounts.isEmpty {
                    VStack(spacing: 8) {
                        Text(L("还没有添加账户", "No accounts yet"))
                            .font(DS.text(14, .medium))
                            .foregroundColor(DS.sub)
                        Text(L("下载并安装应用时需要至少一个账户", "At least one account is needed to install"))
                            .font(DS.text(12))
                            .foregroundColor(DS.sub.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ForEach(engine.accounts) { account in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 9, style: .continuous).fill(DS.canvas)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(DS.ink)
                            }
                            .frame(width: 34, height: 34)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(account.alias)
                                    .font(DS.text(14, .semibold))
                                    .foregroundColor(DS.ink)
                                Text(account.appleID)
                                    .font(DS.text(11))
                                    .foregroundColor(DS.sub)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 0)
                            Button {
                                engine.removeAccount(account)
                            } label: {
                                Text(L("移除", "Remove"))
                                    .font(DS.text(12, .medium))
                                    .foregroundColor(Color(hex: "#C0392B"))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        HDivider().padding(.leading, 62)
                    }
                }

                Button { showAddAccount = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(DS.blue)
                        Text(L("添加 Apple 账户", "Add an Apple account"))
                            .font(DS.text(14, .semibold))
                            .foregroundColor(DS.blue)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#B26B00"))
                    Text(L("建议使用备用账户，不要用主要账户。免费证书签名有一定概率被风控。",
                           "Use a spare account, not your main one. Free certificate signing may be flagged."))
                        .font(DS.text(11))
                        .foregroundColor(Color(hex: "#8A5600"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#FFF6E6"))
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)
        }
    }

    // MARK: 偏好

    private var prefCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L("设置", "Settings"))

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    iconBox("globe")
                    Text(L("语言", "Language"))
                        .font(DS.text(15, .medium))
                        .foregroundColor(DS.ink)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(AppLanguage.allCases) { lang in
                            Button {
                                engine.setLanguage(lang)
                            } label: {
                                Text(lang == .zh ? "中文" : "English")
                                    .font(DS.text(12, .semibold))
                                    .foregroundColor(engine.language == lang ? .white : DS.ink)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(engine.language == lang ? DS.blue : DS.fill))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)

                HDivider().padding(.leading, 56)

                Button { showPrivacy = true } label: {
                    HStack(spacing: 12) {
                        iconBox("hand.raised")
                        Text(L("隐私与数据说明", "Privacy and data"))
                            .font(DS.text(15, .medium))
                            .foregroundColor(DS.ink)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DS.sub.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                .buttonStyle(.plain)

                HDivider().padding(.leading, 56)

                HStack(spacing: 12) {
                    iconBox("internaldrive")
                    Text(L("已安装应用", "Installed apps"))
                        .font(DS.text(15, .medium))
                        .foregroundColor(DS.ink)
                    Spacer()
                    Text("\(engine.installedApps.count)")
                        .font(DS.text(15, .semibold))
                        .foregroundColor(DS.sub)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
            .padding(.horizontal, 20)
        }
    }

    // MARK: 关于

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L("关于", "About"))

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    iconBox("cube.box")
                    Text(L("版本", "Version"))
                        .font(DS.text(15, .medium))
                        .foregroundColor(DS.ink)
                    Spacer()
                    Text("1.0.0")
                        .font(DS.text(14))
                        .foregroundColor(DS.sub)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)

                HDivider().padding(.leading, 56)

                Button {
                    engine.resetOnboarding()
                } label: {
                    HStack(spacing: 12) {
                        iconBox("arrow.counterclockwise")
                        Text(L("清除本地数据", "Clear local data"))
                            .font(DS.text(15, .medium))
                            .foregroundColor(Color(hex: "#C0392B"))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                .buttonStyle(.plain)
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
            .padding(.horizontal, 20)
        }
    }

    private var footer: some View {
        VStack(spacing: 6) {
            AppMark(size: 30)
            Text("App KOP LOP")
                .font(DS.text(12, .semibold))
                .foregroundColor(DS.sub)
            Text(L("客户端 · 签名与安装都在本机完成", "Client · signing and install stay on device"))
                .font(DS.text(11))
                .foregroundColor(DS.sub.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 26)
    }
}

// MARK: - 添加账户

struct AddAccountSheet: View {
    @Environment(\.presentationMode) var presentation
    @State private var alias: String = ""
    @State private var appleID: String = ""

    let onAdd: (String, String) -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(L("添加一个用于签名的 Apple 账户", "Add an Apple account for signing"))
                    .font(DS.text(16, .semibold))
                    .foregroundColor(DS.ink)

                VStack(spacing: 0) {
                    HStack {
                        Text(L("备注", "Label"))
                            .font(DS.text(13, .medium))
                            .foregroundColor(DS.sub)
                            .frame(width: 62, alignment: .leading)
                        TextField(L("例如：备用号", "e.g. spare"), text: $alias)
                            .font(DS.text(15))
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    HDivider().padding(.leading, 14)
                    HStack {
                        Text(L("Apple ID", "Apple ID"))
                            .font(DS.text(13, .medium))
                            .foregroundColor(DS.sub)
                            .frame(width: 62, alignment: .leading)
                        TextField("name@icloud.com", text: $appleID)
                            .font(DS.text(15))
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                }
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(DS.group))

                Text(L("建议使用备用账户，不要用主要账户。免费证书签名有一定概率被风控。",
                       "A spare account is recommended. Free certificate signing may be flagged."))
                    .font(DS.text(12))
                    .foregroundColor(Color(hex: "#8A5600"))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#FFF6E6"))
                    .cornerRadius(10)

                Spacer()

                PrimaryButton(title: L("添加", "Add"), enabled: appleID.contains("@")) {
                    let finalAlias = alias.isEmpty ? L("备用账户", "Spare") : alias
                    onAdd(finalAlias, appleID)
                    presentation.wrappedValue.dismiss()
                }
            }
            .padding(20)
            .navigationBarTitle(L("添加账户", "Add account"), displayMode: .inline)
            .navigationBarItems(trailing: Button(L("取消", "Cancel")) {
                presentation.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - 服务器选择

struct ServerSheet: View {
    @EnvironmentObject var engine: StoreEngine
    @Environment(\.presentationMode) var presentation

    private var options: [(String, String, String, String)] {
        [("auto", "自动", "Auto", L("先试上次成功的服务器，再按成功率轮换内置列表。", "Try the last good server, then rotate the built-in list.")),
         ("local", "本地 AOSKit", "Local AOSKit", L("用设备系统自带的组件在本机生成，不经过任何服务器。", "Generated on device with the system framework, no server.")),
         ("manual", "手动地址", "Manual", L("给自己指定一个 anisette 地址，填写后才生效。", "Point to your own anisette endpoint."))]
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(options.enumerated()), id: \.offset) { idx, opt in
                        Button {
                            engine.setServer(opt.0)
                            presentation.wrappedValue.dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(L(opt.1, opt.2))
                                        .font(DS.text(15, .semibold))
                                        .foregroundColor(DS.ink)
                                    Text(opt.3)
                                        .font(DS.text(11))
                                        .foregroundColor(DS.sub)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 8)
                                if engine.serverMode == opt.0 {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(DS.blue)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if idx < options.count - 1 { HDivider().padding(.leading, 16) }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
                .padding(20)

                Text(L("三种模式都不需要填写密钥。自动模式只在内置列表里换服务器。",
                       "None of these need a key. Auto mode only rotates the built-in list."))
                    .font(DS.text(12))
                    .foregroundColor(DS.sub)
                    .padding(.horizontal, 20)

                Spacer()
            }
            .navigationBarTitle(L("Anisette 服务器", "Anisette server"), displayMode: .inline)
            .navigationBarItems(trailing: Button(L("完成", "Done")) {
                presentation.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - 隐私简表

struct PrivacyShortSheet: View {
    @Environment(\.presentationMode) var presentation

    private var rows: [(String, String, String)] {
        [("本机存储", "On-device", "应用列表、下载记录与语言偏好写在本机。"),
         ("Apple 账户", "Apple account", "只在签名时发往 Apple，凭据存在 Keychain。"),
         ("不收集", "No tracking", "没有分析 SDK，没有行为上报。"),
         ("可清除", "Clearable", "在「我的」里清除本地数据即可恢复首次启动。")]
    }

    private var rowsEN: [(String, String, String)] {
        [("On-device", "On-device", "App list, downloads and language live on this device."),
         ("Apple account", "Apple account", "Sent to Apple only for signing, stored in Keychain."),
         ("No tracking", "No tracking", "No analytics SDK, no behavior upload."),
         ("Clearable", "Clearable", "Clear local data in Me to start over.")]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array((StoreEngine.shared.language == .en ? rowsEN : rows).enumerated()), id: \.offset) { idx, r in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(r.0)
                                .font(DS.text(15, .semibold))
                                .foregroundColor(DS.ink)
                            Text(r.2)
                                .font(DS.text(12))
                                .foregroundColor(DS.sub)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 12)
                        if idx < 3 { HDivider() }
                    }
                }
                .padding(20)
            }
            .navigationBarTitle(L("隐私与数据", "Privacy and data"), displayMode: .inline)
            .navigationBarItems(trailing: Button(L("完成", "Done")) {
                presentation.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - ID 签配置

struct SigningSetupView: View {
    @EnvironmentObject var signing: SigningEngine
    @EnvironmentObject var engine: StoreEngine
    @Environment(\.presentationMode) var presentation

    @State private var appleID: String = ""
    @State private var password: String = ""
    @State private var code: String = ""

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    statusCard

                    if signing.needsCode {
                        codeForm
                    } else if signing.phase == .ready {
                        readyCard
                    } else {
                        loginForm
                    }

                    if let error = signing.lastError, signing.phase == .failed {
                        Text(error)
                            .font(DS.text(12))
                            .foregroundColor(Color(hex: "#C0392B"))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(hex: "#FDECEA")))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(L("这一步做了什么", "What happens here"))
                            .font(DS.text(13, .semibold))
                            .foregroundColor(DS.ink)
                        ForEach(stepLines, id: \.self) { line in
                            HStack(alignment: .top, spacing: 8) {
                                Circle().fill(DS.line).frame(width: 5, height: 5).padding(.top, 6)
                                Text(line)
                                    .font(DS.text(12))
                                    .foregroundColor(DS.sub)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(DS.group))

                    Text(L("全程在设备上完成：anisette 由系统框架本地生成，账号只发往 Apple，证书与描述文件存在本机。",
                           "Everything happens on device: anisette is generated locally, credentials go only to Apple."))
                        .font(DS.text(11))
                        .foregroundColor(DS.sub.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
            }
            .navigationBarTitle(L("签名环境", "Signing environment"), displayMode: .inline)
            .navigationBarItems(trailing: Button(L("完成", "Done")) {
                presentation.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var statusCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(signing.phase == .ready ? Color(hex: "#E8F7EC") : DS.fill)
                Image(systemName: signing.phase == .ready ? "checkmark.seal.fill" : "key.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(signing.phase == .ready ? DS.green : DS.blue)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(signing.phase == .ready ? L("签名环境已就绪", "Ready to sign") : L("签名环境", "Signing environment"))
                    .font(DS.text(16, .semibold))
                    .foregroundColor(DS.ink)
                Text(signing.status.isEmpty ? L("登录后会自动申请证书与描述文件", "Signing in requests the certificate and profile") : signing.status)
                    .font(DS.text(12))
                    .foregroundColor(DS.sub)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(DS.group))
    }

    private var loginForm: some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                HStack {
                    Text(L("Apple ID", "Apple ID"))
                        .font(DS.text(13, .medium))
                        .foregroundColor(DS.sub)
                        .frame(width: 74, alignment: .leading)
                    TextField("name@icloud.com", text: $appleID)
                        .font(DS.text(15))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(.horizontal, 14)
                .frame(height: 50)

                HDivider().padding(.leading, 14)

                HStack {
                    Text(L("密码", "Password"))
                        .font(DS.text(13, .medium))
                        .foregroundColor(DS.sub)
                        .frame(width: 74, alignment: .leading)
                    SecureField(L("账户密码", "Password"), text: $password)
                        .font(DS.text(15))
                }
                .padding(.horizontal, 14)
                .frame(height: 50)
            }
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(DS.group))

            PrimaryButton(title: L("登录并申请证书", "Sign in and request"), enabled: appleID.contains("@") && !password.isEmpty) {
                signing.reset()
                signing.signIn(appleID: appleID, password: password)
                engine.linkAppleID(appleID, password: password)
            }
        }
    }

    private var codeForm: some View {
        VStack(spacing: 12) {
            Text(L("Apple 会向你的设备发送六位验证码", "Apple sends a 6-digit code to your devices"))
                .font(DS.text(13))
                .foregroundColor(DS.sub)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField(L("六位数字", "6 digits"), text: $code)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(DS.group))

            PrimaryButton(title: L("验证", "Verify"), enabled: code.count >= 6) {
                signing.submitCode(code)
                code = ""
            }
        }
    }

    private var readyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            infoLine(L("账户", "Account"), signing.sessionEmail.isEmpty ? engine.appleIDMasked : signing.sessionEmail)
            HDivider()
            infoLine(L("证书", "Certificate"), signing.certificateName.isEmpty ? "—" : signing.certificateName)
            HDivider()
            infoLine(L("App ID 数量", "App IDs"), "\(signing.appIDCount)")
            HDivider()
            infoLine(L("设备", "Device"), UIDevice.current.name)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(DS.group))
    }

    private func infoLine(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(DS.text(12))
                .foregroundColor(DS.sub)
            Spacer()
            Text(value)
                .font(DS.text(12, .medium))
                .foregroundColor(DS.ink)
                .lineLimit(1)
        }
    }

    private var stepLines: [String] {
        [L("用本机 AOSKit 生成 anisette 头，不需要任何服务器", "Generate anisette headers locally with AOSKit"),
         L("向 Apple 登录，必要时输入六位验证码", "Sign in to Apple, enter the 6-digit code when asked"),
         L("登记设备、申请证书与 App ID", "Register the device, request a certificate and App ID"),
         L("生成描述文件，签名环境进入就绪状态", "Create the provisioning profile, then the environment is ready")]
    }
}
