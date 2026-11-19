import Foundation
import SwiftUI
import Security
import Combine

// MARK: - 语言

enum AppLanguage: String, CaseIterable, Identifiable {
    case zh, en
    var id: String { rawValue }
    var title: String { self == .zh ? "简体中文" : "English" }
}

func L(_ zh: String, _ en: String) -> String {
    StoreEngine.shared.language == .en ? en : zh
}

// MARK: - 数据模型

struct UserReview: Codable, Identifiable {
    var id = UUID()
    var appID: String
    var author: String
    var stars: Int
    var title: String
    var text: String
    var createdAt: Date
}

struct StoreReview: Identifiable {
    let id = UUID()
    let author: String
    let stars: Int
    let title: String
    let text: String
    let daysAgo: Int
}

struct StoreApp: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let subtitleEN: String
    let categoryKey: String
    let developer: String
    let description: String
    let descriptionEN: String
    let version: String
    let sizeMB: Double
    let minOS: String
    let languages: [String]
    let website: String
    let repo: String
    let copyright: String
    let rating: Double
    let ratingCount: Int
    let symbol: String
    let colorTop: String
    let colorBottom: String
    let featured: Bool
    let event: String?
    let needsAppID: Bool
    let reviews: [StoreReview]

    var categoryTitle: String {
        switch categoryKey {
        case "game": return L("游戏", "Games")
        case "tool": return L("工具", "Utilities")
        case "launcher": return L("启动器", "Launchers")
        case "dev": return L("开发", "Developer")
        default: return L("应用", "Apps")
        }
    }

    var displayLanguages: String {
        languages.prefix(3).joined(separator: ", ")
    }
}

// 通用评论（按应用名生成，保证详情页有内容）
func makeReviews(_ appName: String) -> [StoreReview] {
    [
        StoreReview(author: "Polaris", stars: 5, title: L("用起来很顺手", "Works great"),
                    text: L("界面干净，点开就能用，没有什么多余的东西。", "Clean UI, opens and just works."), daysAgo: 2),
        StoreReview(author: "小鱼", stars: 4, title: L("希望加个开关", "One setting please"),
                    text: L("整体不错，就是希望能再多一个设置项。", "Good overall, could use one more setting."), daysAgo: 6),
        StoreReview(author: "hjm", stars: 5, title: L("自己做的", "Home made"),
                    text: L("从小做到现在，能装上就已经很满意了。", "Made it from scratch, happy it installs."), daysAgo: 11)
    ]
}

// MARK: - 商店目录（来自 hjm98-rgb 的仓库）

enum Catalog {

    static let apps: [StoreApp] = [
        StoreApp(id: "terracotta", name: "陶瓦联机", subtitle: "轻量组网，房间码直接连",
                 subtitleEN: "Lightweight mesh networking for rooms",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "陶瓦联机是一个只做一件事的工具：把设备拉进同一个房间。内置 EasyTier 组网，配合 Network Extension 保持后台存活，兼容 FCL、HMCL、PCL 的联机房间码。打开、粘贴房间码、连接，三步结束。",
                 descriptionEN: "Terracotta does one thing: pull your devices into the same room. EasyTier mesh networking with a Network Extension for background survival, compatible with FCL / HMCL / PCL room codes.",
                 version: "1.2.0", sizeMB: 28.4, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/terracotta-ios-test",
                 repo: "hjm98-rgb/terracotta-ios-test", copyright: "© 2026 hjm98-rgb",
                 rating: 4.8, ratingCount: 126, symbol: "network", colorTop: "#4C8DFF", colorBottom: "#1E4FC2",
                 featured: true, event: L("本周精选", "Featured"), needsAppID: false, reviews: makeReviews("Terracotta")),

        StoreApp(id: "amethyst", name: "Amethyst 离线版", subtitle: "离线账号也能下载 Minecraft",
                 subtitleEN: "Minecraft launcher with offline downloads",
                 categoryKey: "launcher", developer: "hjm98-rgb",
                 description: "基于 Amethyst 改的 Minecraft Java 启动器，把离线账号下载版本这一环补齐。选择版本、下载资源、进游戏，进度都写在启动页上。",
                 descriptionEN: "An Amethyst-based Minecraft Java launcher that fixes offline account downloads. Pick a version, grab assets, launch.",
                 version: "1.0.6", sizeMB: 62.8, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/Amethyst-OfflineDownload",
                 repo: "hjm98-rgb/Amethyst-OfflineDownload", copyright: "© 2026 hjm98-rgb",
                 rating: 4.6, ratingCount: 208, symbol: "cube.transparent", colorTop: "#9B6BFF", colorBottom: "#5A34C4",
                 featured: true, event: nil, needsAppID: false, reviews: makeReviews("Amethyst")),

        StoreApp(id: "pojav", name: "PojavLauncher", subtitle: "Minecraft Java 版启动器",
                 subtitleEN: "Minecraft Java Edition on iOS",
                 categoryKey: "launcher", developer: "hjm98-rgb",
                 description: "在 iOS 上跑 Minecraft Java 版的老牌启动器。支持 Forge、Fabric、OptiFine，内置资源下载与账号登录。",
                 descriptionEN: "The veteran Minecraft Java launcher for iOS, with Forge, Fabric and OptiFine support.",
                 version: "2.4.5", sizeMB: 74.2, minOS: "iOS 14.0",
                 languages: ["简体中文", "English", "日本語"], website: "https://github.com/hjm98-rgb/PojavLauncher_iOS",
                 repo: "hjm98-rgb/PojavLauncher_iOS", copyright: "© 2026 PojavLauncher",
                 rating: 4.7, ratingCount: 512, symbol: "flame", colorTop: "#FF8A3D", colorBottom: "#D24E12",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("Pojav")),

        StoreApp(id: "jit", name: "JIT RPOQ", subtitle: "RPP + 本地 VPN 的 JIT 引导",
                 subtitleEN: "JIT enabler with RPP and local VPN",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "给模拟器和启动器用的 JIT 引导工具。把 RPP 远程配对、LocalDevVPN 保活和 iOS 26 的脚本串成一条流程，点一次就把需要 JIT 的开关打到正确位置。",
                 descriptionEN: "JIT enabler for emulators and launchers. RPP pairing, LocalDevVPN keep-alive and an iOS 26 script, wired into one tap.",
                 version: "1.1.0", sizeMB: 22.5, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/JIT-RPOQ",
                 repo: "hjm98-rgb/JIT-RPOQ", copyright: "© 2026 hjm98-rgb",
                 rating: 4.5, ratingCount: 88, symbol: "bolt.fill", colorTop: "#FFD166", colorBottom: "#C98A00",
                 featured: true, event: L("刚刚上架", "New"), needsAppID: false, reviews: makeReviews("JIT RPOQ")),

        StoreApp(id: "myworld", name: "我的世界启动器", subtitle: "改名、自研界面、免费云打包",
                 subtitleEN: "Custom Minecraft launcher",
                 categoryKey: "launcher", developer: "hjm98-rgb",
                 description: "基于开源引擎二次开发的启动器，换了自己的名字和界面，版本管理与资源下载都收在一页里。",
                 descriptionEN: "A launcher rebuilt from an open-source engine with its own name and interface.",
                 version: "1.0.2", sizeMB: 58.3, minOS: "iOS 15.0",
                 languages: ["简体中文"], website: "https://github.com/hjm98-rgb/myworldlauncher",
                 repo: "hjm98-rgb/myworldlauncher", copyright: "© 2026 hjm98-rgb",
                 rating: 4.3, ratingCount: 64, symbol: "hammer.fill", colorTop: "#8FA7C8", colorBottom: "#4E6480",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("MyWorld")),

        StoreApp(id: "cubecraft", name: "方块世界 CubeCraft", subtitle: "Godot 4 做的体素世界",
                 subtitleEN: "Voxel world built with Godot 4",
                 categoryKey: "game", developer: "hjm98-rgb",
                 description: "用 Godot 4 搭的体素沙盒，目前停在主菜单框架阶段：世界生成、方块放置和第一人称移动已经能跑，界面还在长。",
                 descriptionEN: "A voxel sandbox built with Godot 4. World generation, block placement and first-person movement are in.",
                 version: "0.4.0", sizeMB: 96.1, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/CubeCraft",
                 repo: "hjm98-rgb/CubeCraft", copyright: "© 2026 hjm98-rgb",
                 rating: 4.4, ratingCount: 41, symbol: "cube.fill", colorTop: "#31D6A2", colorBottom: "#0E8F6A",
                 featured: true, event: L("秋季活动 · 试玩", "Autumn event"), needsAppID: false, reviews: makeReviews("CubeCraft")),

        StoreApp(id: "combat", name: "Combat Strike 3D", subtitle: "多平台 FPS，带武器商店",
                 subtitleEN: "Multi-platform FPS with weapon shop",
                 categoryKey: "game", developer: "hjm98-rgb",
                 description: "Godot 4.2 做的第一人称射击：登录、教程、大厅、武器商店、机器人、活动和地图都在包里，Windows / Android / iOS 自动构建。",
                 descriptionEN: "A first person shooter on Godot 4.2: login, tutorial, lobby, weapon shop, bots, events and maps included.",
                 version: "0.6.3", sizeMB: 142.5, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/combat-strike-3d",
                 repo: "hjm98-rgb/combat-strike-3d", copyright: "© 2026 hjm98-rgb",
                 rating: 4.2, ratingCount: 57, symbol: "scope", colorTop: "#FF5C7A", colorBottom: "#B01F43",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("Combat Strike")),

        StoreApp(id: "collect3d", name: "3D 宝石收集", subtitle: "小体量 3D 收集游戏",
                 subtitleEN: "A small 3D collect game",
                 categoryKey: "game", developer: "hjm98-rgb",
                 description: "一关一个小目标：在场景里把宝石收齐。轻量、上手快，适合随手玩几分钟。",
                 descriptionEN: "One goal per level: collect all the gems. Light, quick to pick up.",
                 version: "1.0.0", sizeMB: 34.7, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/3DCollectGame",
                 repo: "hjm98-rgb/3DCollectGame", copyright: "© 2026 hjm98-rgb",
                 rating: 4.1, ratingCount: 23, symbol: "sparkles", colorTop: "#7FD8FF", colorBottom: "#2288C9",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("3D Collect")),

        StoreApp(id: "dbengine", name: "DBEngine", subtitle: "自己写的跨平台 2D 引擎",
                 subtitleEN: "A home-made cross-platform 2D engine",
                 categoryKey: "dev", developer: "hjm98-rgb",
                 description: "软渲染的 2D 游戏引擎，Android / iOS / 桌面三端跑同一份工程，自带编辑器。适合把想法快速拼成能玩的东西。",
                 descriptionEN: "A software-rendered 2D engine for Android, iOS and desktop, with its own editor.",
                 version: "0.9.1", sizeMB: 41.9, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/DBEngine",
                 repo: "hjm98-rgb/DBEngine", copyright: "© 2026 hjm98-rgb",
                 rating: 4.5, ratingCount: 32, symbol: "scribble.variable", colorTop: "#FFB020", colorBottom: "#B57500",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("DBEngine")),

        StoreApp(id: "fnf", name: "FNF Psych Engine", subtitle: "节奏对战引擎",
                 subtitleEN: "Rhythm battle engine",
                 categoryKey: "game", developer: "hjm98-rgb",
                 description: "Friday Night Funkin 的 Psych Engine 版本，谱面、角色和模组按文件夹丢进去就能跑。",
                 descriptionEN: "Psych Engine build of Friday Night Funkin. Drop charts, characters and mods into folders and play.",
                 version: "0.7.1", sizeMB: 210.4, minOS: "iOS 15.0",
                 languages: ["English", "简体中文"], website: "https://github.com/hjm98-rgb/FNF-PsychEngine",
                 repo: "hjm98-rgb/FNF-PsychEngine", copyright: "© 2026 Psych Engine",
                 rating: 4.6, ratingCount: 149, symbol: "music.note", colorTop: "#FF7AD9", colorBottom: "#A1208C",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("Psych Engine")),

        StoreApp(id: "flowerfell", name: "Flowerfell", subtitle: "Ren'Py 像素剧情",
                 subtitleEN: "Ren'Py pixel story",
                 categoryKey: "game", developer: "hjm98-rgb",
                 description: "Ren'Py 做的同人剧情，按章节往下推，存档存在本地。画面和音乐都在包里，不用联网。",
                 descriptionEN: "A Ren'Py fan story that moves chapter by chapter, with local saves.",
                 version: "0.4.1", sizeMB: 128.7, minOS: "iOS 15.0",
                 languages: ["简体中文"], website: "https://github.com/hjm98-rgb/flowerfell-ipa",
                 repo: "hjm98-rgb/flowerfell-ipa", copyright: "© 2026 hjm98-rgb",
                 rating: 4.4, ratingCount: 76, symbol: "theatermasks.fill", colorTop: "#FF9E6B", colorBottom: "#C45215",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("Flowerfell")),

        StoreApp(id: "glauncher", name: "GameLauncher", subtitle: "内置虚拟机引擎的启动器",
                 subtitleEN: "Launcher with a built-in VM engine",
                 categoryKey: "launcher", developer: "hjm98-rgb",
                 description: "iOS 上把游戏和虚拟机引擎放在一起的启动器：选镜像、起环境、进游戏，都在同一个界面里。",
                 descriptionEN: "An iOS launcher that bundles game images with a VM engine.",
                 version: "0.8.4", sizeMB: 88.6, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/GameLauncher",
                 repo: "hjm98-rgb/GameLauncher", copyright: "© 2026 hjm98-rgb",
                 rating: 4.0, ratingCount: 19, symbol: "gamecontroller.fill", colorTop: "#5FD3FF", colorBottom: "#1C7FA8",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("GameLauncher")),

        StoreApp(id: "signdock", name: "SignDock", subtitle: "原生 SwiftUI 签名客户端",
                 subtitleEN: "Native SwiftUI signing client",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "不做网页壳的原生签名客户端：导入证书、挂描述文件、选包、出已签名 IPA，进度和日志都在一页里。",
                 descriptionEN: "A native signing client: import certificates, attach profiles, pick an IPA, get a signed build.",
                 version: "1.0.3", sizeMB: 33.2, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/signdock-native",
                 repo: "hjm98-rgb/signdock-native", copyright: "© 2026 hjm98-rgb",
                 rating: 4.7, ratingCount: 93, symbol: "signature", colorTop: "#6E8BFF", colorBottom: "#2C3FB8",
                 featured: true, event: nil, needsAppID: false, reviews: makeReviews("SignDock")),

        StoreApp(id: "eversign", name: "EverSign", subtitle: "常驻的 IPA 安装器",
                 subtitleEN: "A permanent IPA installer",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "把签名好的包交给系统安装的那一层，装完留在设备上，不用每次重新来一遍。",
                 descriptionEN: "Hands signed packages to the system installer and keeps them around afterwards.",
                 version: "1.1.2", sizeMB: 26.8, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/eversign",
                 repo: "hjm98-rgb/eversign", copyright: "© 2026 hjm98-rgb",
                 rating: 4.3, ratingCount: 47, symbol: "arrow.down.circle.fill", colorTop: "#54C7A8", colorBottom: "#137A5E",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("EverSign")),

        StoreApp(id: "swiftsign", name: "SwiftSign", subtitle: "开源签名工具",
                 subtitleEN: "Open-source signing tool",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "开源的 iOS 签名工具，配云打包流水线用：本地签、云端签两种模式都在。",
                 descriptionEN: "An open-source iOS signing tool built for cloud packaging, with local and remote modes.",
                 version: "1.4.0", sizeMB: 29.5, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/SwiftSign",
                 repo: "hjm98-rgb/SwiftSign", copyright: "© 2026 hjm98-rgb",
                 rating: 4.2, ratingCount: 31, symbol: "checkmark.seal.fill", colorTop: "#8FA0FF", colorBottom: "#3B4BB5",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("SwiftSign")),

        StoreApp(id: "isign", name: "iSign 云签", subtitle: "签名与分发后台",
                 subtitleEN: "Signing and distribution backend",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "官网加签名管理后台的一套云签方案，签名任务交给云端的流水线去跑。",
                 descriptionEN: "A cloud signing setup with a site and a signing admin backend.",
                 version: "2.0.0", sizeMB: 18.4, minOS: "iOS 15.0",
                 languages: ["简体中文"], website: "https://github.com/hjm98-rgb/isign",
                 repo: "hjm98-rgb/isign", copyright: "© 2026 hjm98-rgb",
                 rating: 4.0, ratingCount: 16, symbol: "cloud.fill", colorTop: "#7CC6FF", colorBottom: "#1E6FB0",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("iSign")),

        StoreApp(id: "jitenabler", name: "iOS JIT Enabler", subtitle: "给 JIT 开一扇门",
                 subtitleEN: "Opens the door for JIT",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "生成可安装的 IPA，专门处理 JIT 相关的那档设置，iOS 14 起都能用。",
                 descriptionEN: "Produces installable IPAs and handles the JIT settings, iOS 14 and up.",
                 version: "1.5.1", sizeMB: 15.7, minOS: "iOS 14.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/ios-jit-enabler",
                 repo: "hjm98-rgb/ios-jit-enabler", copyright: "© 2026 hjm98-rgb",
                 rating: 4.4, ratingCount: 71, symbol: "cpu", colorTop: "#B0A6FF", colorBottom: "#5B4BC4",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("JIT Enabler")),

        StoreApp(id: "totp", name: "TOTP 验证器", subtitle: "本地生成，不联网",
                 subtitleEN: "Local TOTP codes, offline",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "TOTP 两步验证器，密钥只放在本机 Keychain，生成的六位数不上传。",
                 descriptionEN: "A TOTP authenticator with keys kept in the local Keychain.",
                 version: "1.0.4", sizeMB: 11.3, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/TOTPAuthenticator",
                 repo: "hjm98-rgb/TOTPAuthenticator", copyright: "© 2026 hjm98-rgb",
                 rating: 4.8, ratingCount: 38, symbol: "lock.shield.fill", colorTop: "#67D7A5", colorBottom: "#146F4D",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("TOTP")),

        StoreApp(id: "agent", name: "AI Device Agent", subtitle: "设备端 agent + 桌面端",
                 subtitleEN: "On-device agent with a desktop buddy",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "iOS 端的小 agent：接上桌面端的 worker，就能在设备上跑任务、看状态。",
                 descriptionEN: "An on-device agent that pairs with a desktop worker to run tasks and watch status.",
                 version: "0.3.2", sizeMB: 24.9, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/ai-device-agent",
                 repo: "hjm98-rgb/ai-device-agent", copyright: "© 2026 hjm98-rgb",
                 rating: 4.1, ratingCount: 12, symbol: "dot.radiowaves.left.and.right", colorTop: "#9AE6FF", colorBottom: "#2C7EA1",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("Agent")),

        StoreApp(id: "realfps", name: "RealFPS", subtitle: "把帧率钉在屏幕上",
                 subtitleEN: "Frame rate pinned on screen",
                 categoryKey: "tool", developer: "hjm98-rgb",
                 description: "小小的帧率显示器，叠在游戏上面看实时 FPS，不占资源。",
                 descriptionEN: "A tiny FPS overlay that stays on top of your game.",
                 version: "1.0.1", sizeMB: 9.8, minOS: "iOS 15.0",
                 languages: ["简体中文", "English"], website: "https://github.com/hjm98-rgb/realfps-native",
                 repo: "hjm98-rgb/realfps-native", copyright: "© 2026 hjm98-rgb",
                 rating: 4.3, ratingCount: 27, symbol: "gauge", colorTop: "#FFD166", colorBottom: "#A86F00",
                 featured: false, event: nil, needsAppID: false, reviews: makeReviews("RealFPS"))
    ]

    static let categories: [(key: String, zh: String, en: String)] = [
        ("all", "全部", "All"),
        ("game", "游戏", "Games"),
        ("tool", "工具", "Utilities"),
        ("launcher", "启动器", "Launchers"),
        ("dev", "开发", "Developer")
    ]

    static func filtered(_ key: String) -> [StoreApp] {
        if key == "all" { return apps }
        return apps.filter { $0.categoryKey == key }
    }

    static func search(_ text: String) -> [StoreApp] {
        let q = text.trimmingCharacters(in: .whitespaces).lowercased()
        if q.isEmpty { return [] }
        return apps.filter {
            $0.name.lowercased().contains(q) || $0.subtitle.lowercased().contains(q) || $0.developer.lowercased().contains(q)
        }
    }
}

// MARK: - 签名账户

struct SigningAccount: Identifiable, Codable {
    var id: String = UUID().uuidString
    var alias: String
    var appleID: String
    var addedAt: Date = Date()
    var slotsUsed: Int = 0
}

// MARK: - Keychain

enum KeychainStore {
    private static let service = "com.hjm98.appkoplop"

    static func save(_ value: String, key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
        var attrs = query
        attrs[kSecValueData as String] = data
        attrs[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        SecItemAdd(attrs as CFDictionary, nil)
    }

    static func read(_ key: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ key: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - 下载引擎

enum DownloadPhase {
    case idle, downloading, downloaded, installing, signed, installed
}

struct DownloadState {
    var progress: Double = 0
    var phase: DownloadPhase = .idle
    var localPath: String?
}

// 每个应用对应的最新未签名包。空着表示仓库还没出 Release。
let packageURLs: [String: String] = [
    "jit": "https://github.com/hjm98-rgb/JIT-RPOQ/releases/download/v1.4.1/JITRPOQ-1.4.1-unsigned.ipa",
    "amethyst": "https://github.com/hjm98-rgb/Amethyst-Offline/releases/download/v1.1/org.angelauramc.amethyst-1.0-ios.ipa"
]

final class IPADownloader: NSObject, URLSessionDownloadDelegate {
    static let shared = IPADownloader()

    private lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    private var ids: [Int: String] = [:]
    private var tasks: [String: URLSessionDownloadTask] = [:]

    func start(appID: String, url: URL) {
        let t = session.downloadTask(with: url)
        ids[t.taskIdentifier] = appID
        tasks[appID] = t
        t.resume()
    }

    func cancel(appID: String) {
        tasks[appID]?.cancel()
        tasks[appID] = nil
    }

    func urlSession(_ s: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let id = ids[downloadTask.taskIdentifier] else { return }
        let p = totalBytesExpectedToWrite > 0 ? min(1, Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)) : 0
        StoreEngine.shared.updateDownload(id, progress: p)
    }

    func urlSession(_ s: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let id = ids[downloadTask.taskIdentifier] else { return }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Downloads")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let dest = dir.appendingPathComponent("\(id).ipa")
        try? FileManager.default.removeItem(at: dest)
        do {
            try FileManager.default.moveItem(at: location, to: dest)
            StoreEngine.shared.finishDownload(id, path: dest)
        } catch {
            StoreEngine.shared.failDownload(id, error.localizedDescription)
        }
    }

    func urlSession(_ s: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let id = ids[task.taskIdentifier], let e = error else { return }
        StoreEngine.shared.failDownload(id, e.localizedDescription)
    }
}

final class StoreEngine: ObservableObject {

    static let shared = StoreEngine()

    @Published var language: AppLanguage = .zh
    @Published var didAcceptPrivacy: Bool = false
    @Published var didFinishOnboarding: Bool = false
    @Published var appleIDLinked: Bool = false
    @Published var appleIDMasked: String = ""
    @Published var appleIDSkipped: Bool = false

    @Published var states: [String: DownloadState] = [:]
    @Published var accounts: [SigningAccount] = []
    @Published var serverMode: String = "auto"
    @Published var vpnConnected: Bool = false
    @Published var currentTab: Int = 0
    @Published var selectedApp: StoreApp?
    @Published var toast: String?
    @Published var userReviews: [UserReview] = []

    private var timer: Timer?
    private let defaults = UserDefaults.standard
    private var toastWork: DispatchWorkItem?

    var appIDQuota: Int { 3 }
    var appIDsUsed: Int { accounts.reduce(0) { $0 + $1.slotsUsed } }
    var appIDsLeft: Int { max(0, appIDQuota - appIDsUsed) }
    var signedAccountCount: Int { accounts.count }

    var serverLabel: String {
        switch serverMode {
        case "local": return L("本地 AOSKit", "Local AOSKit")
        case "manual": return L("手动地址", "Manual")
        default: return L("自动（按成功率轮换）", "Auto (by success rate)")
        }
    }

    private init() {
        language = defaults.string(forKey: "lang").flatMap(AppLanguage.init(rawValue:)) ?? .zh
        didAcceptPrivacy = defaults.bool(forKey: "privacy")
        didFinishOnboarding = defaults.bool(forKey: "onboarded")
        appleIDLinked = defaults.bool(forKey: "appleLinked")
        appleIDMasked = defaults.string(forKey: "appleMask") ?? ""
        appleIDSkipped = defaults.bool(forKey: "appleSkipped")
        serverMode = defaults.string(forKey: "serverMode") ?? "auto"
        vpnConnected = defaults.bool(forKey: "vpn")

        if let data = defaults.data(forKey: "accounts"),
           let decoded = try? JSONDecoder().decode([SigningAccount].self, from: data) {
            accounts = decoded
        }
        if let data = defaults.data(forKey: "userReviews"),
           let decoded = try? JSONDecoder().decode([UserReview].self, from: data) {
            userReviews = decoded
        }
        var initial: [String: DownloadState] = [:]
        let installed = defaults.stringArray(forKey: "installed") ?? []
        for id in installed { initial[id] = DownloadState(progress: 1, phase: .installed) }
        states = initial

        timer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            self?.tick()
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }

    // MARK: 引导

    func acceptPrivacy() {
        didAcceptPrivacy = true
        defaults.set(true, forKey: "privacy")
    }

    func linkAppleID(_ id: String, password: String) {
        appleIDLinked = true
        appleIDSkipped = false
        let mask = maskEmail(id)
        appleIDMasked = mask
        defaults.set(true, forKey: "appleLinked")
        defaults.set(mask, forKey: "appleMask")
        defaults.set(false, forKey: "appleSkipped")
        KeychainStore.save(id, key: "appleID")
        KeychainStore.save(password, key: "applePwd")
    }

    func skipAppleID() {
        appleIDSkipped = true
        appleIDLinked = false
        defaults.set(true, forKey: "appleSkipped")
        defaults.set(false, forKey: "appleLinked")
    }

    func completeOnboarding() {
        didFinishOnboarding = true
        defaults.set(true, forKey: "onboarded")
    }

    func resetOnboarding() {
        didFinishOnboarding = false
        didAcceptPrivacy = false
        defaults.set(false, forKey: "onboarded")
        defaults.set(false, forKey: "privacy")
    }

    private func maskEmail(_ id: String) -> String {
        guard let at = id.firstIndex(of: "@") else {
            return id.count > 3 ? "\(id.prefix(2))***" : id
        }
        let head = id[..<at]
        let tail = id[at...]
        if head.count <= 2 { return "***\(tail)" }
        return "\(head.prefix(2))***\(tail)"
    }

    // MARK: 评论

    func reviews(for app: StoreApp) -> [StoreReview] {
        let mine = userReviews.filter { $0.appID == app.id }.sorted { $0.createdAt > $1.createdAt }
            .map { r -> StoreReview in
                let days = max(0, Calendar.current.dateComponents([.day], from: r.createdAt, to: Date()).day ?? 0)
                return StoreReview(author: r.author, stars: r.stars, title: r.title, text: r.text, daysAgo: days)
            }
        return mine + app.reviews
    }

    func addReview(app: StoreApp, stars: Int, title: String, text: String, author: String) {
        let r = UserReview(appID: app.id, author: author.isEmpty ? "我" : author,
                           stars: max(1, min(5, stars)), title: title, text: text, createdAt: Date())
        userReviews.insert(r, at: 0)
        if let data = try? JSONEncoder().encode(userReviews) {
            defaults.set(data, forKey: "userReviews")
        }
        showToast(L("评论已发布", "Review posted"))
    }

    func averageRating(for app: StoreApp) -> Double {
        let all = reviews(for: app)
        guard !all.isEmpty else { return app.rating }
        let sum = all.reduce(0) { $0 + $1.stars }
        let base = Double(sum) / Double(all.count)
        if all.count >= 5 { return base }
        // 少量评论时和原始评分做加权，避免一条五星把分数顶满
        let weight = Double(app.ratingCount) / Double(app.ratingCount + all.count)
        return (app.rating * weight) + (base * (1 - weight))
    }

    // MARK: 下载

    func state(for app: StoreApp) -> DownloadState {
        states[app.id] ?? DownloadState()
    }

    func startDownload(_ app: StoreApp) {
        let s = state(for: app)
        if s.phase != .idle { return }
        guard let str = packageURLs[app.id], let url = URL(string: str) else {
            showToast(L("这款还没出安装包，仓库有 Release 后自动出现", "No package yet"))
            return
        }
        states[app.id] = DownloadState(progress: 0, phase: .downloading)
        IPADownloader.shared.start(appID: app.id, url: url)
    }

    func updateDownload(_ id: String, progress: Double) {
        var s = states[id] ?? DownloadState()
        s.progress = progress
        s.phase = .downloading
        states[id] = s
    }

    func finishDownload(_ id: String, path: URL) {
        var s = states[id] ?? DownloadState()
        s.progress = 1
        s.phase = .downloaded
        s.localPath = path.path
        states[id] = s
        if let app = Catalog.apps.first(where: { $0.id == id }) {
            autoSign(app)
        }
    }

    // 一键：下载完自动签名，签名完自动安装
    private func autoSign(_ app: StoreApp) {
        guard SigningEngine.shared.phase == .ready else {
            showToast(L("下载好了，去「我的 → 签名环境」配置一次，之后都自动签名", "Downloaded. Set up signing once"))
            return
        }
        sign(app)
    }

    func failDownload(_ id: String, _ message: String) {
        states[id] = DownloadState()
        showToast(L("下载失败：", "Download failed: ") + message)
    }

    func sign(_ app: StoreApp) {
        guard let path = state(for: app).localPath else { return }
        guard SigningEngine.shared.phase == .ready else {
            showToast(L("先去「我的 → 签名环境」配置证书", "Set up signing first"))
            return
        }
        var s = state(for: app)
        s.phase = .installing
        states[app.id] = s
        SigningEngine.shared.sign(appAt: URL(fileURLWithPath: path)) { [weak self] output in
            guard let self = self else { return }
            DispatchQueue.main.async {
                var f = self.state(for: app)
                if let out = output {
                    f.phase = .signed
                    f.localPath = out.path
                    self.states[app.id] = f
                    self.installSigned(app, path: out.path)
                } else {
                    f.phase = .downloaded
                    self.states[app.id] = f
                    self.showToast(L("签名失败，看签名环境里的错误", "Signing failed"))
                }
            }
        }
    }

    private func installSigned(_ app: StoreApp, path: String) {
        AppInstaller.install(path: path) { ok, message in
            var f = self.state(for: app)
            if ok {
                f.phase = .installed
                self.states[app.id] = f
                self.persistInstalled()
                self.showToast(L("已安装到桌面", "Installed to Home Screen"))
            } else {
                f.phase = .signed
                self.states[app.id] = f
                self.showToast(L("签名完成，系统安装接口拒绝：", "Signed, install API refused: ") + message)
            }
        }
    }

    func cancelDownload(_ app: StoreApp) {
        IPADownloader.shared.cancel(appID: app.id)
        states[app.id] = DownloadState(progress: 0, phase: .idle)
    }

    private func tick() {
        // 真实下载由 IPADownloader 回报进度，这里不做模拟推进
    }
    private func persistInstalled() {
        let ids = states.filter { $0.value.phase == .installed }.map { $0.key }
        defaults.set(ids, forKey: "installed")
    }

    var installedApps: [StoreApp] {
        Catalog.apps.filter { state(for: $0).phase == .installed }
    }

    var downloadingCount: Int {
        states.values.filter { $0.phase == .downloading || $0.phase == .installing }.count
    }

    // MARK: 账户

    func addAccount(alias: String, appleID: String) {
        accounts.append(SigningAccount(alias: alias, appleID: appleID))
        persistAccounts()
    }

    func removeAccount(_ account: SigningAccount) {
        accounts.removeAll { $0.id == account.id }
        persistAccounts()
    }

    private func persistAccounts() {
        if let data = try? JSONEncoder().encode(accounts) {
            defaults.set(data, forKey: "accounts")
        }
    }

    // MARK: 设置

    func setLanguage(_ lang: AppLanguage) {
        language = lang
        defaults.set(lang.rawValue, forKey: "lang")
    }

    func setServer(_ mode: String) {
        serverMode = mode
        defaults.set(mode, forKey: "serverMode")
    }

    func toggleVPN() {
        vpnConnected.toggle()
        defaults.set(vpnConnected, forKey: "vpn")
        showToast(vpnConnected ? L("本地循环通道已连接", "Loopback channel connected") : L("本地循环通道已断开", "Loopback channel disconnected"))
    }

    func showToast(_ text: String) {
        toast = text
        toastWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            withAnimation { self?.toast = nil }
        }
        toastWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2, execute: work)
    }

    func open(_ app: StoreApp) {
        selectedApp = app
    }

    func closeDetail() {
        selectedApp = nil
    }
}

// MARK: - 安装

enum AppInstaller {
    typealias InstallFn = @convention(c) (CFString, CFDictionary, UnsafeMutablePointer<CFString?>?) -> Int32

    static func install(path: String, completion: @escaping (Bool, String) -> Void) {
        let fw = "/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation"
        guard let handle = dlopen(fw, RTLD_NOW), let sym = dlsym(handle, "MobileInstallationInstall") else {
            completion(false, "no mobileinstallation")
            return
        }
        let fn = unsafeBitCast(sym, to: InstallFn.self)
        let options: [String: Any] = ["ApplicationType": "User", "IsUpgrade": true]
        var errorLabel: CFString?
        let code = fn(path as CFString, options as CFDictionary, &errorLabel)
        if code == 0 {
            completion(true, "")
        } else {
            completion(false, "code \(code)")
        }
    }
}

// MARK: - 安装（系统私有接口）

enum AppInstaller {
    private typealias InstallFn = @convention(c) (CFString, CFDictionary, UnsafeMutablePointer<CFString?>?) -> Int32

    /// 用系统的 MobileInstallation 装已签名包。未越狱设备上是否放行取决于签名时注入的权限。
    static func install(path: String, completion: @escaping (Bool, String) -> Void) {
        guard FileManager.default.fileExists(atPath: path) else {
            completion(false, L("打不开已签名包", "Signed package missing"))
            return
        }
        guard let handle = dlopen("/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation", RTLD_NOW),
              let symbol = dlsym(handle, "MobileInstallationInstall") else {
            completion(false, L("系统没有开放安装接口", "Install API unavailable"))
            return
        }
        let fn = unsafeBitCast(symbol, to: InstallFn.self)
        var errorLabel: CFString?
        let options = ["ApplicationType": "User", "IsUpgrade": true] as CFDictionary
        let code = fn(path as CFString, options, &errorLabel)
        if code == 0 {
            completion(true, "")
        } else {
            let label = (errorLabel as String?) ?? ""
            completion(false, "code \(code) \(label)")
        }
    }
}
