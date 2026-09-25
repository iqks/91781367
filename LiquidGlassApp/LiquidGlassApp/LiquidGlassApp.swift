import SwiftUI

@main
struct LiquidGlassApp: App {
    @State private var noticeText = ""
    @State private var noticeLink: String?
    @State private var showNotice = false
    @AppStorage("remoteURL") private var remoteURL = "https://iqks.github.io/91781367/notice.json"
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
    func parseTextNotice(_ pageText: String) {
        let lines = pageText.components(separatedBy: .newlines)
        var content = ""
        var link = ""
        var state = 0 // 0=等待"公告" 1=读取公告文字 2=读取放链接
        for raw in lines {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if line == "\"公告\"" { state = 1; continue }
            if line == "\"放链接\"" { state = 2; continue }
            if line.isEmpty { continue }
            let cleaned = line.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            if state == 1 {
                content = cleaned
            } else if state == 2 {
                link = cleaned
            }
        }
        noticeText = content
        noticeLink = link.isEmpty ? nil : link
    }
}
