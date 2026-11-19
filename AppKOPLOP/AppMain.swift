import SwiftUI

// MARK: - 设计系统

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if s.count == 3 { s = s.map { String($0) + String($0) }.joined() }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r = Double((value & 0xFF0000) >> 16) / 255
        let g = Double((value & 0x00FF00) >> 8) / 255
        let b = Double(value & 0x0000FF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

enum DS {
    static let blue = Color(hex: "#0A84FF")
    static let ink = Color(hex: "#111114")
    static let sub = Color(hex: "#6E6E73")
    static let line = Color(hex: "#E6E6EB")
    static let canvas = Color(hex: "#FFFFFF")
    static let group = Color(hex: "#F6F6F8")
    static let fill = Color(hex: "#F1F1F4")
    static let green = Color(hex: "#2FB344")

    static func title(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .default) }
    static func text(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font { .system(size: size, weight: weight) }
}

// MARK: - 图标

struct AppIconTile: View {
    let app: StoreApp
    var size: CGFloat = 60
    var corner: CGFloat { size * 0.235 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: app.colorTop), Color(hex: app.colorBottom)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: app.symbol)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - 通用组件

struct PrimaryButton: View {
    let title: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DS.text(17, .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(enabled ? DS.blue : DS.blue.opacity(0.35)))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct GhostButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DS.text(16, .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundColor(DS.sub)
        }
        .buttonStyle(.plain)
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(DS.text(22, .bold))
            .foregroundColor(DS.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 10)
    }
}

struct HDivider: View {
    var body: some View {
        Rectangle().fill(DS.line).frame(height: 1)
    }
}

struct StarRow: View {
    let rating: Double
    var size: CGFloat = 11
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { i in
                Image(systemName: symbol(i))
                    .font(.system(size: size))
                    .foregroundColor(Color(hex: "#F5A623"))
            }
        }
    }
    private func symbol(_ i: Int) -> String {
        let v = rating - Double(i)
        if v >= 0.75 { return "star.fill" }
        if v >= 0.25 { return "star.leadinghalf.filled" }
        return "star"
    }
}

// MARK: - App 入口

@main
struct AppKOPLOPApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(StoreEngine.shared)
                .environmentObject(SigningEngine.shared)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var engine: StoreEngine

    var body: some View {
        ZStack {
            DS.canvas.ignoresSafeArea()
            if engine.didFinishOnboarding {
                MainShellView()
            } else {
                OnboardingView()
            }
            if let toast = engine.toast {
                VStack {
                    Text(toast)
                        .font(DS.text(14, .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.black.opacity(0.82)))
                        .padding(.top, 8)
                    Spacer()
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
    }
}

// MARK: - 引导

struct OnboardingView: View {
    enum Step { case privacy, loading, account }
    @EnvironmentObject var engine: StoreEngine
    @State private var step: Step = .privacy

    var body: some View {
        ZStack {
            DS.canvas.ignoresSafeArea()
            switch step {
            case .privacy:
                PrivacyView { withAnimation(.easeInOut(duration: 0.35)) { step = .loading } }
            case .loading:
                LoadingView {
                    withAnimation(.easeInOut(duration: 0.35)) { step = .account }
                }
            case .account:
                AppleIDView {
                    engine.completeOnboarding()
                }
            }
        }
    }
}

struct PrivacyView: View {
    @EnvironmentObject var engine: StoreEngine

    let onContinue: () -> Void

    private let points: [(String, String, String)] = [
        ("lock.shield.fill", "只留在本机", "Only on this device"),
        ("person.crop.circle", "账号仅用于签名", "Account used for signing only"),
        ("trash.fill", "随时可清除", "Clear anytime")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    AppMark(size: 64)
                        .padding(.top, 28)

                    Text(L("先读一下这份说明", "Before we start"))
                        .font(DS.title(30))
                        .foregroundColor(DS.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L("App KOP LOP 是一个装在你设备上的应用商店。它不收集你的浏览记录，不上传你的应用列表，也不需要你注册任何账号才能用。",
                           "App KOP LOP is an app store that runs on your device. It does not collect your browsing history or upload your app list."))
                        .font(DS.text(16))
                        .foregroundColor(DS.sub)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 0) {
                        ForEach(Array(points.enumerated()), id: \.offset) { idx, p in
                            HStack(spacing: 14) {
                                Image(systemName: p.0)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(DS.blue)
                                    .frame(width: 26)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(L(p.1, p.2))
                                        .font(DS.text(16, .semibold))
                                        .foregroundColor(DS.ink)
                                    Text(detail(idx))
                                        .font(DS.text(13))
                                        .foregroundColor(DS.sub)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 14)
                            if idx < points.count - 1 { HDivider().padding(.leading, 40) }
                        }
                    }
                    .padding(.horizontal, 16)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))

                    Text(L("点继续即表示你已阅读并同意以上说明。这份说明只会在首次启动时出现，之后除非重装应用，不会再打扰你。",
                           "Tap Continue to accept. This notice appears once, and will not show again unless you reinstall the app."))
                        .font(DS.text(13))
                        .foregroundColor(DS.sub.opacity(0.9))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 12)
                }
                .padding(.horizontal, 24)
            }

            VStack(spacing: 0) {
                PrimaryButton(title: L("继续", "Continue")) {
                    engine.acceptPrivacy()
                    onContinue()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
            .background(DS.canvas)
        }
    }

    private func detail(_ idx: Int) -> String {
        switch idx {
        case 0: return L("应用列表、下载记录、语言偏好都存在本机，不上传到任何服务器。", "App list, downloads and language stay on this device.")
        case 1: return L("只有在你主动填写时才会用到 Apple ID，用途仅限申请签名证书，不走任何第三方。", "Your Apple ID is used only for signing certificates, never through a third party.")
        case 2: return L("在「我的」里可以一键清除本地数据并重新开始。", "You can clear local data anytime in Me.")
        default: return ""
        }
    }
}

struct AppMark: View {
    var size: CGFloat = 72
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.235, style: .continuous)
                .fill(Color(hex: "#0A0E17"))
            VStack(spacing: size * 0.035) {
                RoundedRectangle(cornerRadius: size * 0.026, style: .continuous)
                    .fill(Color(hex: "#F3EEE4"))
                    .frame(width: size * 0.4, height: size * 0.12)
                RoundedRectangle(cornerRadius: size * 0.026, style: .continuous)
                    .fill(Color(hex: "#FF7A2F"))
                    .frame(width: size * 0.52, height: size * 0.13)
                RoundedRectangle(cornerRadius: size * 0.026, style: .continuous)
                    .fill(Color(hex: "#2E7BFF"))
                    .frame(width: size * 0.64, height: size * 0.14)
            }
        }
        .frame(width: size, height: size)
    }
}

struct LoadingView: View {
    let onDone: () -> Void
    @State private var progress: CGFloat = 0
    @State private var showSpinner = false
    @State private var labelIndex = 0

    private let labels: [(String, String)] = [
        ("正在读取应用目录", "Reading catalog"),
        ("正在准备商城界面", "Preparing store"),
        ("正在检查本地通道", "Checking local channel")
    ]

    var body: some View {
        VStack(spacing: 26) {
            Spacer()
            AppMark(size: 76)
            Text(L("正在准备", "Preparing"))
                .font(DS.title(24))
                .foregroundColor(DS.ink)

            ZStack {
                if showSpinner {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: DS.sub))
                        .scaleEffect(1.1)
                } else {
                    VStack(spacing: 12) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(DS.fill).frame(height: 6)
                                Capsule().fill(DS.blue)
                                    .frame(width: max(6, geo.size.width * progress), height: 6)
                            }
                        }
                        .frame(height: 6)
                        .frame(width: 200)
                        Text(L(labels[labelIndex].0, labels[labelIndex].1))
                            .font(DS.text(13))
                            .foregroundColor(DS.sub)
                    }
                }
            }
            .frame(height: 56)

            Spacer()
        }
        .onAppear { run() }
    }

    private func run() {
        let total = 1.6
        let stepTime = 0.04
        var elapsed: Double = 0
        Timer.scheduledTimer(withTimeInterval: stepTime, repeats: true) { timer in
            elapsed += stepTime
            let p = min(1, CGFloat(elapsed / total))
            progress = p
            if p > 0.35 { labelIndex = 1 }
            if p > 0.7 { labelIndex = 2 }
            if p >= 1 {
                timer.invalidate()
                showSpinner = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    onDone()
                }
            }
        }
    }
}

struct AppleIDView: View {
    @EnvironmentObject var engine: StoreEngine
    let onDone: () -> Void

    @State private var appleID: String = ""
    @State private var password: String = ""
    @State private var showSkipHint = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(DS.blue)
                        Text(L("连接 Apple 账户", "Connect an Apple account"))
                            .font(DS.title(22))
                            .foregroundColor(DS.ink)
                    }
                    .padding(.top, 32)

                    Text(L("填写后，「我的」里就能看到可签名的账户，下载时会用这个账户申请证书。也可以先跳过，之后在「我的」里再添加。",
                           "Once filled, the account shows up in Me and is used for signing. You can skip and add it later."))
                        .font(DS.text(15))
                        .foregroundColor(DS.sub)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 0) {
                        HStack {
                            Text(L("Apple ID", "Apple ID"))
                                .font(DS.text(14, .semibold))
                                .foregroundColor(DS.sub)
                                .frame(width: 88, alignment: .leading)
                            TextField("name@icloud.com", text: $appleID)
                                .font(DS.text(16))
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 54)

                        HDivider().padding(.leading, 16)

                        HStack {
                            Text(L("密码", "Password"))
                                .font(DS.text(14, .semibold))
                                .foregroundColor(DS.sub)
                                .frame(width: 88, alignment: .leading)
                            SecureField(L("账户密码", "Account password"), text: $password)
                                .font(DS.text(16))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                    }
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(DS.group))

                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 13))
                            .foregroundColor(DS.sub)
                        Text(L("凭据只保存在本机 Keychain，用于向 Apple 申请签名证书，不会经过第三方服务器。",
                               "Credentials stay in the local Keychain and are sent only to Apple for signing."))
                            .font(DS.text(12))
                            .foregroundColor(DS.sub)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(L("建议使用备用账户，不要用日常主力账户。免费证书签名存在被系统风控的概率。",
                           "A spare account is recommended. Free certificate signing may be flagged."))
                        .font(DS.text(12))
                        .foregroundColor(Color(hex: "#B26B00"))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(hex: "#FFF6E6")))
                }
                .padding(.horizontal, 24)
            }

            VStack(spacing: 6) {
                PrimaryButton(title: L("继续", "Continue"), enabled: canSubmit) {
                    engine.linkAppleID(appleID, password: password)
                    engine.addAccount(alias: L("默认账户", "Default"), appleID: appleID)
                    onDone()
                }
                .padding(.horizontal, 24)

                GhostButton(title: L("先跳过", "Skip for now")) {
                    engine.skipAppleID()
                    onDone()
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(DS.canvas)
        }
    }

    private var canSubmit: Bool {
        appleID.contains("@") && password.count >= 1
    }
}

// MARK: - 主壳

struct MainShellView: View {
    @EnvironmentObject var engine: StoreEngine

    var body: some View {
        ZStack {
            DS.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                TopTabs()
                ZStack {
                    if engine.currentTab == 0 {
                        StoreHomeView()
                    } else if engine.currentTab == 1 {
                        SearchView()
                    } else {
                        MeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if let app = engine.selectedApp {
                AppDetailView(app: app)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(5)
            }
        }
    }
}

struct TopTabs: View {
    @EnvironmentObject var engine: StoreEngine

    private var items: [(String, String, String)] {
        [("storefront.fill", "商城", "Store"),
         ("magnifyingglass", "搜索", "Search"),
         ("person.fill", "我的", "Me")]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { engine.currentTab = idx }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: item.0)
                                .font(.system(size: 13, weight: .semibold))
                            Text(L(item.1, item.2))
                                .font(DS.text(14, .semibold))
                        }
                        .foregroundColor(engine.currentTab == idx ? .white : DS.ink)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            Capsule().fill(engine.currentTab == idx ? DS.blue : DS.fill)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 10)

            HDivider()
        }
        .background(DS.canvas)
    }
}

// MARK: - 商城首页

struct StoreHomeView: View {
    @EnvironmentObject var engine: StoreEngine
    @State private var category: String = "all"
    @State private var visibleCount: Int = 8

    private var filtered: [StoreApp] { Catalog.filtered(category) }
    private var shown: [StoreApp] { Array(filtered.prefix(visibleCount)) }
    private var featured: [StoreApp] { Catalog.apps.filter { $0.featured } }
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                eventBanner
                SectionHeader(title: L("编辑精选", "Editors' picks"))
                featuredRow
                SectionHeader(title: L("分类", "Categories"))
                categoryRow
                SectionHeader(title: L("正在上架", "Available now"))
                appGrid
                if visibleCount < filtered.count {
                    Button {
                        withAnimation { visibleCount += 8 }
                    } label: {
                        Text(L("显示更多", "Show more"))
                            .font(DS.text(15, .semibold))
                            .foregroundColor(DS.blue)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
                footer
            }
            .padding(.bottom, 30)
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L("商城", "Store"))
                    .font(DS.title(32))
                    .foregroundColor(DS.ink)
                Text(L("为你挑选的应用与游戏", "Apps and games picked for you"))
                    .font(DS.text(14))
                    .foregroundColor(DS.sub)
            }
            Spacer()
            Button {
                engine.currentTab = 2
            } label: {
                if engine.appleIDLinked {
                    Text(engine.appleIDMasked)
                        .font(DS.text(12, .semibold))
                        .foregroundColor(DS.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(DS.fill))
                } else {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 26))
                        .foregroundColor(DS.sub)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private var eventBanner: some View {
        Button {
            if let app = Catalog.apps.first(where: { $0.id == "cubecraft" }) { engine.open(app) }
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L("秋季活动", "Autumn event"))
                        .font(DS.text(11, .bold))
                        .foregroundColor(.white.opacity(0.75))
                        .tracking(0.6)
                    Text(L("方块世界 · 开放试玩", "CubeCraft · open playtest"))
                        .font(DS.text(19, .bold))
                        .foregroundColor(.white)
                    Text(L("活动期间直接下载，不需要额外签名次数", "Free to download during the event"))
                        .font(DS.text(12))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer(minLength: 0)
                AppIconTile(app: Catalog.apps.first(where: { $0.id == "cubecraft" })!, size: 54)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: "#14324F"), Color(hex: "#0B1622")],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .buttonStyle(.plain)
    }

    private var featuredRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(featured) { app in
                    Button { engine.open(app) } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            AppIconTile(app: app, size: 52)
                            Text(app.name)
                                .font(DS.text(15, .semibold))
                                .foregroundColor(DS.ink)
                                .lineLimit(1)
                            Text(L(app.subtitle, app.subtitleEN))
                                .font(DS.text(11))
                                .foregroundColor(DS.sub)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(height: 30, alignment: .top)
                        }
                        .padding(14)
                        .frame(width: 158, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
        }
    }

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Catalog.categories, id: \.key) { c in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            category = c.key
                            visibleCount = 8
                        }
                    } label: {
                        Text(L(c.zh, c.en))
                            .font(DS.text(13, .semibold))
                            .foregroundColor(category == c.key ? .white : DS.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(category == c.key ? DS.ink : DS.fill))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var appGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(shown) { app in
                Button { engine.open(app) } label: {
                    VStack(alignment: .leading, spacing: 9) {
                        AppIconTile(app: app, size: 58)
                        Text(app.name)
                            .font(DS.text(14, .semibold))
                            .foregroundColor(DS.ink)
                            .lineLimit(1)
                        Text(L(app.subtitle, app.subtitleEN))
                            .font(DS.text(11))
                            .foregroundColor(DS.sub)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(height: 30, alignment: .top)
                        HStack(spacing: 4) {
                            StarRow(rating: app.rating, size: 9)
                            Text(String(format: "%.1f", app.rating))
                                .font(DS.text(10))
                                .foregroundColor(DS.sub)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 2)
    }

    private var footer: some View {
        VStack(spacing: 6) {
            AppMark(size: 26)
            Text(L("App KOP LOP · 本机签名与安装", "App KOP LOP · sign and install on device"))
                .font(DS.text(11))
                .foregroundColor(DS.sub.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 28)
    }
}
