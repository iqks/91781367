import SwiftUI

@main
struct LiquidGlassApp: App {
    @State private var noticeText = ""
    @State private var noticeLink: String?
    @State private var showNotice = false
    @AppStorage("remoteURL") private var remoteURL = "https://store.eoty.cn/%E5%85%AC%E5%91%8A.txt/nOzHI_arx2Ne-wCE2R6P"
    @Environment(\.openURL) private var openURL

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await fetchAnnouncement()
                }
                .alert("公告", isPresented: $showNotice) {
                    Button("知道了", role: .cancel) {}
                    if let link = noticeLink, !link.isEmpty, let url = URL(string: link) {
                        Button("立即更新") {
                            openURL(url)
                        }
                    }
                } message: {
                    Text(noticeText)
                }
        }
    }

    /// 一进入 App 就从后台拉公告，弹出系统原生警告框
    func fetchAnnouncement() async {
        var urlString = remoteURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString.hasSuffix("/") { urlString.removeLast() }
        if !urlString.contains("/api/content") && !urlString.hasSuffix(".json") {
            urlString += "/api/content"
        }
        guard let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // 1) 先尝试 JSON 格式（本地后台 / GitHub 公告）
            if let remote = try? JSONDecoder().decode(RemoteData.self, from: data) {
                let text = remote.announcements
                    .map { a -> String in
                        var s = ""
                        if !a.title.isEmpty { s += a.title + "\n" }
                        s += a.content
                        return s
                    }
                    .joined(separator: "\n\n")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty {
                    noticeLink = remote.announcements.first(where: { !($0.link ?? "").isEmpty })?.link
                    noticeText = text
                    showNotice = true
                }
                return
            }
            // 2) 否则按"云小店网页文本"格式解析：
            //    "公告"
            //    "公告里的文字"
            //    "放链接"
            //    "https://..."
            if let pageText = String(data: data, encoding: .utf8) {
                parseTextNotice(pageText)
                if !noticeText.isEmpty {
                    showNotice = true
                }
            }
        } catch {
            // 后台连不上就不弹，App 正常进入主界面
        }
    }

    /// 解析云小店网页文本格式的公告
    /// 支持两种写法：
    /// 1) "公告" "公告里的文字" "https://链接"
    /// 2) "公告" / "公告里的文字" / "放链接"https://链接
    func parseTextNotice(_ pageText: String) {
        var quotes: [String] = []
        if let regex = try? NSRegularExpression(pattern: "\"([^\"]*)\"") {
            let ns = pageText as NSString
            let results = regex.matches(in: pageText, range: NSRange(location: 0, length: ns.length))
            for m in results {
                let r = m.range(at: 1)
                if r.location != NSNotFound { quotes.append(ns.substring(with: r)) }
            }
        }
        // 找到 "公告" 标记
        guard let idx = quotes.firstIndex(of: "公告") else { return }
        var text = ""
        var link = ""
        for q in quotes[(idx + 1)...] where q != "放链接" {
            if text.isEmpty { text = q } else { link = q; break }
        }
        // 兜底：如果"放链接"标记同一行后面直接跟了链接（引号外）
        if link.isEmpty, let range = pageText.range(of: "\"放链接\"") {
            var rest = Substring(pageText[range.upperBound...])
            rest = rest.drop(while: { $0 == " " || $0 == "\"" || $0 == "\t" })
            let candidate = rest.prefix(while: { !$0.isNewline && $0 != " " && $0 != "\"" })
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !candidate.isEmpty { link = candidate }
        }
        noticeText = text
        noticeLink = link.isEmpty ? nil : link
    }
}
