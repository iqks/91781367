import SwiftUI

@main
struct LiquidGlassApp: App {
    @State private var noticeText = ""
    @State private var showNotice = false
    @AppStorage("remoteURL") private var remoteURL = "http://localhost:8088"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await fetchAnnouncement()
                }
                .alert("公告", isPresented: $showNotice) {
                    Button("知道了", role: .cancel) {}
                } message: {
                    Text(noticeText)
                }
        }
    }

    /// 一进入 App 就从后台拉公告，弹出系统原生警告框
    func fetchAnnouncement() async {
        var urlString = remoteURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString.hasSuffix("/") { urlString.removeLast() }
        if !urlString.contains("/api/content") { urlString += "/api/content" }
        guard let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let remote = try JSONDecoder().decode(RemoteData.self, from: data)
            let text = remote.announcements
                .map { a -> String in
                    var s = ""
                    if !a.title.isEmpty { s += a.title + "\n" }
                    s += a.content
                    return s
                }
                .joined(separator: "\n\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            noticeText = text
            showNotice = true
        } catch {
            // 后台连不上就不弹，App 正常进入主界面
        }
    }
}
