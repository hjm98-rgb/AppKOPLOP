import SwiftUI
import UIKit

// MARK: - 应用详情

struct AppDetailView: View {
    @EnvironmentObject var engine: StoreEngine
    let app: StoreApp

    @State private var expanded = false

    private var state: DownloadState { engine.state(for: app) }

    var body: some View {
        ZStack {
            DS.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        head
                        downloadRow
                        statsRow
                        screenshots
                        descriptionBlock
                        infoBlock
                        developerBlock
                        languageBlock
                        reviewsBlock
                        reportRow
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: 顶栏

    private var navBar: some View {
        HStack {
            Button { engine.closeDetail() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DS.blue)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(DS.fill))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(app.name)
                .font(DS.text(15, .semibold))
                .foregroundColor(DS.ink)
                .lineLimit(1)
                .opacity(0)

            Spacer()

            Button { engine.showToast(L("已加入分享列表", "Added to share sheet")) } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DS.blue)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 4)
        .background(DS.canvas)
    }

    // MARK: 头部

    private var head: some View {
        VStack(spacing: 12) {
            AppIconTile(app: app, size: 92)

            Text(app.name)
                .font(DS.title(26))
                .foregroundColor(DS.ink)
                .multilineTextAlignment(.center)

            Text(L(app.subtitle, app.subtitleEN))
                .font(DS.text(14))
                .foregroundColor(DS.sub)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                engine.currentTab = 2
            } label: {
                Text(app.developer)
                    .font(DS.text(14, .semibold))
                    .foregroundColor(DS.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 6)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)
    }

    // MARK: 下载

    private var downloadRow: some View {
        VStack(spacing: 8) {
            switch state.phase {
            case .idle:
                Button { engine.startDownload(app) } label: {
                    Text(L("获取", "Get"))
                        .font(DS.text(16, .bold))
                        .foregroundColor(.white)
                        .frame(width: 132, height: 42)
                        .background(Capsule().fill(DS.blue))
                }
                .buttonStyle(.plain)

            case .downloading:
                Button { engine.cancelDownload(app) } label: {
                    ProgressRing(progress: state.progress)
                }
                .buttonStyle(.plain)
                Text(String(format: "%.0f%%", state.progress * 100))
                    .font(DS.text(12, .medium))
                    .foregroundColor(DS.sub)

            case .downloaded:
                Button { engine.sign(app) } label: {
                    Text(L("签名", "Sign"))
                        .font(DS.text(16, .bold))
                        .foregroundColor(.white)
                        .frame(width: 132, height: 42)
                        .background(Capsule().fill(DS.blue))
                }
                .buttonStyle(.plain)
                Text(L("已下载，待签名", "Downloaded, ready to sign"))
                    .font(DS.text(12, .medium))
                    .foregroundColor(DS.sub)

            case .installing:
                ProgressRing(progress: 1)
                Text(L("正在签名", "Signing"))
                    .font(DS.text(12, .medium))
                    .foregroundColor(DS.sub)

            case .signed:
                Button { engine.showToast(L("已签名包在「文件 → 本机 → AppKOPLOP → Downloads」", "Signed file is in Files → Downloads")) } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                        Text(L("已签名", "Signed"))
                            .font(DS.text(16, .bold))
                    }
                    .foregroundColor(DS.blue)
                    .frame(width: 132, height: 42)
                    .background(Capsule().fill(DS.fill))
                }
                .buttonStyle(.plain)

            case .installed:
                Button { engine.showToast(L("已安装，可在桌面打开", "Installed, open from Home Screen")) } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                        Text(L("打开", "Open"))
                            .font(DS.text(16, .bold))
                    }
                    .foregroundColor(DS.blue)
                    .frame(width: 132, height: 42)
                    .background(Capsule().fill(DS.fill))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            stat(L("评分", "Rating"), String(format: "%.1f", app.rating), StarRow(rating: app.rating, size: 9))
            divider
            stat(L("年龄", "Age"), "4+", EmptyView())
            divider
            stat(L("类别", "Category"), app.categoryTitle, EmptyView())
        }
        .padding(.vertical, 14)
        .padding(.top, 8)
    }

    private var divider: some View {
        Rectangle().fill(DS.line).frame(width: 1, height: 34)
    }

    private func stat<C: View>(_ label: String, _ value: String, _ extra: C) -> some View {
        VStack(spacing: 5) {
            Text(label.uppercased())
                .font(DS.text(10, .semibold))
                .foregroundColor(DS.sub)
            Text(value)
                .font(DS.text(19, .bold))
                .foregroundColor(DS.ink)
            extra
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: 截图

    private var screenshots: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: shotColors(i), startPoint: .top, endPoint: .bottom))
                        .frame(width: 148, height: 264)
                        .overlay(
                            VStack(spacing: 10) {
                                Image(systemName: app.symbol)
                                    .font(.system(size: 34, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.92))
                                Text(shotCaption(i))
                                    .font(DS.text(12, .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 6)
        .padding(.bottom, 6)
    }

    private func shotColors(_ i: Int) -> [Color] {
        let c1 = Color(hex: app.colorTop)
        let c2 = Color(hex: app.colorBottom)
        switch i {
        case 0: return [c1, c2]
        case 1: return [c2, Color.black.opacity(0.55)]
        default: return [Color(hex: "#101318"), c1.opacity(0.6)]
        }
    }

    private func shotCaption(_ i: Int) -> String {
        switch i {
        case 0: return L("主界面", "Main screen")
        case 1: return L("详情与设置", "Details and settings")
        default: return L("本地通道", "Local channel")
        }
    }

    // MARK: 描述

    private var descriptionBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L(app.description, app.descriptionEN))
                .font(DS.text(15))
                .foregroundColor(DS.ink.opacity(0.86))
                .lineSpacing(5)
                .lineLimit(expanded ? nil : 4)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                Text(expanded ? L("收起", "Less") : L("更多", "More"))
                    .font(DS.text(14, .semibold))
                    .foregroundColor(DS.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: 信息

    private var infoBlock: some View {
        VStack(spacing: 0) {
            infoRow(L("开发者", "Developer"), app.developer, valueBlue: true)
            HDivider().padding(.leading, 20)
            infoRow(L("大小", "Size"), String(format: "%.1f MB", app.sizeMB), valueBlue: false)
            HDivider().padding(.leading, 20)
            infoRow(L("类别", "Category"), app.categoryTitle, valueBlue: false)
            HDivider().padding(.leading, 20)
            infoRow(L("版本", "Version"), app.version, valueBlue: false)
            HDivider().padding(.leading, 20)
            infoRow(L("兼容性", "Compatibility"), "iPadOS / iOS " + app.minOS.replacingOccurrences(of: "iOS ", with: ""), valueBlue: false)
            HDivider().padding(.leading, 20)
            infoRow(L("支持语言", "Languages"), app.displayLanguages, valueBlue: false)
            HDivider().padding(.leading, 20)
            infoRow(L("App ID", "App ID"),
                    app.needsAppID ? L("需要 1 个签名名额", "Uses 1 signing slot") : L("已内置，不消耗名额", "Included, no slot used"),
                    valueBlue: false)
        }
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private func infoRow(_ label: String, _ value: String, valueBlue: Bool) -> some View {
        HStack {
            Text(label)
                .font(DS.text(14))
                .foregroundColor(DS.sub)
            Spacer()
            Text(value)
                .font(DS.text(14, .medium))
                .foregroundColor(valueBlue ? DS.blue : DS.ink)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    // MARK: 开发者

    private var developerBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L("开发者", "Developer"))

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(DS.fill)
                        Text("H")
                            .font(DS.text(18, .bold))
                            .foregroundColor(DS.ink)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(app.developer)
                            .font(DS.text(16, .semibold))
                            .foregroundColor(DS.ink)
                        Text(L("独立开发者 · 中国", "Independent developer · China"))
                            .font(DS.text(12))
                            .foregroundColor(DS.sub)
                    }
                    Spacer()
                }
                .padding(16)

                HDivider().padding(.leading, 16)

                linkRow(L("开发者官网", "Website"), app.website)
                HDivider().padding(.leading, 16)
                linkRow(L("开源仓库", "Repository"), "github.com/" + app.repo)
                HDivider().padding(.leading, 16)
                HStack {
                    Text(L("版权", "Copyright"))
                        .font(DS.text(14))
                        .foregroundColor(DS.sub)
                    Spacer()
                    Text(app.copyright)
                        .font(DS.text(13))
                        .foregroundColor(DS.ink)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)

                HDivider().padding(.leading, 16)

                HStack {
                    Text(L("隐私", "Privacy"))
                        .font(DS.text(14))
                        .foregroundColor(DS.sub)
                    Spacer()
                    Text(L("不收集数据", "No data collected"))
                        .font(DS.text(13, .medium))
                        .foregroundColor(DS.ink)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
            .padding(.horizontal, 20)
        }
    }

    private func linkRow(_ label: String, _ url: String) -> some View {
        Button {
            engine.showToast(L("已复制链接", "Link copied"))
            UIPasteboard.general.string = url.hasPrefix("http") ? url : "https://" + url
        } label: {
            HStack {
                Text(label)
                    .font(DS.text(14))
                    .foregroundColor(DS.sub)
                Spacer()
                Text(url)
                    .font(DS.text(13, .medium))
                    .foregroundColor(DS.blue)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(DS.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }

    // MARK: 语言

    private var languageBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L("支持的语言", "Languages"))
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    ForEach(app.languages, id: \.self) { lang in
                        Text(lang)
                            .font(DS.text(12, .medium))
                            .foregroundColor(DS.ink)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(DS.canvas))
                            .overlay(Capsule().stroke(DS.line, lineWidth: 1))
                    }
                    Spacer(minLength: 0)
                }
                Text(L("应用内界面语言：跟随系统", "In-app language follows the system"))
                    .font(DS.text(12))
                    .foregroundColor(DS.sub)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
            .padding(.horizontal, 20)
        }
    }

    // MARK: 评论

    private var reviewsBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L("评分与评论", "Ratings and reviews"))

            HStack(alignment: .center, spacing: 18) {
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", app.rating))
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(DS.ink)
                    StarRow(rating: app.rating, size: 12)
                    Text("\(app.ratingCount) " + L("个评分", "ratings"))
                        .font(DS.text(11))
                        .foregroundColor(DS.sub)
                }
                .frame(width: 110)

                VStack(spacing: 6) {
                    ForEach((1...5).reversed(), id: \.self) { star in
                        HStack(spacing: 6) {
                            Text("\(star)")
                                .font(DS.text(10))
                                .foregroundColor(DS.sub)
                                .frame(width: 8)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(DS.line).frame(height: 5)
                                    Capsule().fill(DS.ink.opacity(0.55))
                                        .frame(width: geo.size.width * barValue(star), height: 5)
                                }
                            }
                            .frame(height: 5)
                        }
                    }
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(app.reviews.enumerated()), id: \.element.id) { idx, review in
                    reviewCell(review)
                    if idx < app.reviews.count - 1 { HDivider().padding(.leading, 16) }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }

    private func barValue(_ star: Int) -> CGFloat {
        let base: [Int: CGFloat] = [5: 0.72, 4: 0.18, 3: 0.06, 2: 0.03, 1: 0.01]
        return base[star] ?? 0
    }

    private func reviewCell(_ r: StoreReview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(r.author)
                    .font(DS.text(14, .semibold))
                    .foregroundColor(DS.ink)
                Spacer()
                Text("\(r.daysAgo) " + L("天前", "d ago"))
                    .font(DS.text(11))
                    .foregroundColor(DS.sub)
            }
            StarRow(rating: Double(r.stars), size: 9)
            Text(r.title)
                .font(DS.text(13, .semibold))
                .foregroundColor(DS.ink)
            Text(r.text)
                .font(DS.text(13))
                .foregroundColor(DS.sub)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
    }

    private var reportRow: some View {
        Button {
            engine.showToast(L("已记录，我们会检查", "Report noted"))
        } label: {
            Text(L("报告问题", "Report a problem"))
                .font(DS.text(13))
                .foregroundColor(DS.sub)
                .padding(.vertical, 18)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 下载圆环

struct ProgressRing: View {
    let progress: Double
    @State private var spinning = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.28), lineWidth: 3)
            Circle()
                .trim(from: 0, to: CGFloat(max(0.02, progress)))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.12), value: progress)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.62)
                .rotationEffect(.degrees(spinning ? 360 : 0))
        }
        .frame(width: 58, height: 58)
        .padding(5)
        .background(Circle().fill(DS.blue))
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                spinning = true
            }
        }
    }
}

// MARK: - 搜索

struct SearchView: View {
    @EnvironmentObject var engine: StoreEngine
    @State private var query: String = ""
    @FocusState private var focused: Bool

    private var results: [StoreApp] { Catalog.search(query) }
    private var recommendations: [StoreApp] { Array(Catalog.apps.filter { !$0.featured }.prefix(6)) }
    private var chips: [String] { ["启动器", "签名", "方块", "JIT", "音游", "FPS"] }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                emptyState
            } else {
                resultState
            }
        }
        .background(DS.canvas)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DS.sub)
                TextField(L("搜索应用、工具或游戏", "Search apps, tools or games"), text: $query)
                    .font(DS.text(15))
                    .focused($focused)
                    .autocorrectionDisabled(true)
                    .submitLabel(.search)
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(DS.sub.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(DS.fill))

            if focused || !query.isEmpty {
                Button {
                    query = ""
                    focused = false
                } label: {
                    Text(L("取消", "Cancel"))
                        .font(DS.text(15, .medium))
                        .foregroundColor(DS.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    private var emptyState: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(title: L("推荐搜索", "Suggested"))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(chips, id: \.self) { chip in
                            Button {
                                query = chip
                            } label: {
                                Text(chip)
                                    .font(DS.text(13, .medium))
                                    .foregroundColor(DS.ink)
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(DS.fill))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                SectionHeader(title: L("推荐应用", "Recommended"))
                VStack(spacing: 0) {
                    ForEach(recommendations) { app in
                        appRow(app)
                        if app.id != recommendations.last?.id {
                            HDivider().padding(.leading, 76)
                        }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
                .padding(.horizontal, 20)

                Text(L("搜索会同时匹配应用名、副标题与开发者。", "Search matches name, subtitle and developer."))
                    .font(DS.text(12))
                    .foregroundColor(DS.sub.opacity(0.8))
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
            }
            .padding(.bottom, 30)
        }
    }

    private var resultState: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(results.isEmpty
                         ? L("没有找到相关应用", "No results")
                         : L("找到 \(results.count) 个结果", "\(results.count) results"))
                        .font(DS.text(13, .medium))
                        .foregroundColor(DS.sub)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 8)

                if results.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 26))
                            .foregroundColor(DS.sub.opacity(0.6))
                        Text(L("试试别的关键词，或从推荐里挑一个", "Try another keyword, or pick from suggestions"))
                            .font(DS.text(13))
                            .foregroundColor(DS.sub)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 0) {
                        ForEach(results) { app in
                            appRow(app)
                            if app.id != results.last?.id {
                                HDivider().padding(.leading, 76)
                            }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(DS.group))
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 30)
        }
    }

    private func appRow(_ app: StoreApp) -> some View {
        Button { engine.open(app) } label: {
            HStack(spacing: 14) {
                AppIconTile(app: app, size: 48)
                VStack(alignment: .leading, spacing: 3) {
                    Text(app.name)
                        .font(DS.text(15, .semibold))
                        .foregroundColor(DS.ink)
                        .lineLimit(1)
                    Text(L(app.subtitle, app.subtitleEN))
                        .font(DS.text(11))
                        .foregroundColor(DS.sub)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        StarRow(rating: app.rating, size: 8)
                        Text(String(format: "%.1f", app.rating))
                            .font(DS.text(10))
                            .foregroundColor(DS.sub)
                    }
                }
                Spacer(minLength: 6)
                Text(L("获取", "Get"))
                    .font(DS.text(13, .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(DS.blue))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}
