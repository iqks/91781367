import SwiftUI
import PhotosUI
import UIKit
import WebKit
import UniformTypeIdentifiers

// ============================================================
//  签名助手 App —— SwiftUI 原生版
//
//  · 底部导航栏：TabView（系统原生 TabBar，App Store 同款）
//  · 3 个主页面（首页/下载/设置）+ 组件演示子页面
//  · 全部使用系统原生组件，iOS 26 自动呈现液态玻璃材质，
//    旧系统自动回退原生磨砂，无需任何判断代码
// ============================================================

struct ContentView: View {
    @StateObject private var downloader = DownloadManager()
    @State private var selectedTab = 0
    @AppStorage("darkMode") private var darkMode = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(downloader)
                .tabItem { Label("首页", systemImage: "house.fill") }
                .tag(0)
            DownloadView()
                .environmentObject(downloader)
                .tabItem { Label("下载", systemImage: "arrow.down.circle.fill") }
                .tag(1)
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape.fill") }
                .tag(2)
        }
        .onChange(of: downloader.shouldJumpToDownload) { _ in
            // 下载完成自动跳到「下载」页
            if downloader.shouldJumpToDownload {
                selectedTab = 1
                downloader.shouldJumpToDownload = false
            }
        }
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}

/// 下载管理器：点「获取」下载 IPA 到 App 的 Downloads 目录
class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    struct DownloadItem: Identifiable {
        let id = UUID()
        let name: String
        let url: URL
        var state: String      // downloading / done / error
        var progress: Double
        var path: URL?
    }

    @Published var items: [DownloadItem] = []
    @Published var signedItems: [DownloadItem] = []
    @Published var shouldJumpToDownload = false   // 下载完成 → 跳下载页
    @Published var shouldRemoveCard = false       // 下载失败（链接失效）→ 删除卡片
    private var taskMap: [URLSessionTask: UUID] = [:]
    private lazy var session: URLSession = {
        let cfg = URLSessionConfiguration.default
        return URLSession(configuration: cfg, delegate: self, delegateQueue: .main)
    }()

    func startDownload(url: URL) {
        let name = url.lastPathComponent.isEmpty ? "应用.ipa" : url.lastPathComponent
        let item = DownloadItem(name: name, url: url, state: "downloading", progress: 0, path: nil)
        items.append(item)
        let task = session.downloadTask(with: url)
        taskMap[task] = item.id
        task.resume()
    }

    // 下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let id = taskMap[downloadTask],
              let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].progress = totalBytesExpectedToWrite > 0
            ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            : 0
    }

    // 下载完成：移到 Downloads 目录
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let id = taskMap[downloadTask],
              let idx = items.firstIndex(where: { $0.id == id }) else { return }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Downloads", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let dest = dir.appendingPathComponent(items[idx].name)
        try? FileManager.default.moveItem(at: location, to: dest)
        items[idx].state = "done"
        items[idx].progress = 1.0
        items[idx].path = dest
        taskMap[downloadTask] = nil
        // 下载完成：自动跳转到下载页
        shouldJumpToDownload = true
    }

    // 下载出错
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error != nil,
              let id = taskMap[task],
              let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].state = "error"
        taskMap[task] = nil
        // 下载失败（链接失效）：删除卡片
        shouldRemoveCard = true
    }
}

/// 云端应用信息（后台 /api/content 返回）
struct RemoteContent: Codable {
    let app: RemoteApp?
}

struct RemoteApp: Codable {
    let name: String
    let desc: String
    let link: String
    let time: String
    let icon: String?
}

// MARK: - 页面 1：底部导航栏

struct TabBarView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("这就是苹果官方底部导航栏（TabView / UITabBar）", systemImage: "rectangle.bottomthird.inset.filled")
                    Label("iOS 26 自动启用液态玻璃材质", systemImage: "drop.fill")
                    Label("旧系统自动回退原生磨砂", systemImage: "circle.lefthalf.filled")
                    Label("点击下方标签即可切换页面", systemImage: "hand.tap")
                    Label("超过 5 个标签时系统自动出现「更多」", systemImage: "ellipsis.circle")
                }
                if #available(iOS 26.0, *) {
                    Section("液态玻璃演示") {
                        Label("iOS 26 真机上的液态玻璃", systemImage: "sparkles")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect()
                    }
                }
            }
            .navigationTitle("底部导航栏")
        }
    }
}

// MARK: - 页面 2：苹果原生按钮

struct ButtonView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("默认按钮") {
                    Button("普通按钮") {}
                    Button {} label: {
                        Label("带图标按钮", systemImage: "square.and.arrow.up")
                    }
                    Button("自动样式") {}
                        .buttonStyle(.automatic)
                    Button("无边框样式") {}
                        .buttonStyle(.borderless)
                    Button("纯文本样式") {}
                        .buttonStyle(.plain)
                }
                Section("官方按钮样式") {
                    Button("填充蓝色（Prominent）") {}
                        .buttonStyle(.borderedProminent)
                    Button("描边样式（Bordered）") {}
                        .buttonStyle(.bordered)
                    Button("灰色胶囊") {}
                        .buttonStyle(.borderedProminent)
                        .tint(.gray)
                        .clipShape(Capsule())
                    Button("红色危险操作", role: .destructive) {}
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    Button("绿色确认") {}
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    Button("紫色强调") {}
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    Button("橙色提醒") {}
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                }
                Section("带图标按钮") {
                    Button {} label: {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                    Button {} label: {
                        Label("下载", systemImage: "arrow.down.circle")
                    }
                    .buttonStyle(.bordered)
                    Button {} label: {
                        Label("删除", systemImage: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                Section("大按钮与全宽") {
                    Button("全宽蓝色大按钮") {}
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    Button("全宽描边") {}
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("原生按钮")
        }
    }
}

// MARK: - 页面 3：苹果原生滑动条

struct SliderView: View {
    @State private var value = 0.5
    @State private var stepValue = 3.0
    @State private var minValue = 0.0
    @State private var maxValue = 100.0
    @State private var volume = 0.4

    var body: some View {
        NavigationStack {
            List {
                Section("基本滑动条") {
                    Slider(value: $value)
                    Text("当前值：\(value, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("系统强调色") {
                    Slider(value: $value).tint(.blue)
                    Slider(value: $value).tint(.green)
                    Slider(value: $value).tint(.red)
                    Slider(value: $value).tint(.orange)
                    Slider(value: $value).tint(.purple)
                }
                Section("步进滑动条（每次 +1）") {
                    Slider(value: $stepValue, in: 0...10, step: 1)
                    Text("当前：\(Int(stepValue))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("带范围滑动条") {
                    Slider(value: $minValue, in: 0...100)
                    Text("当前：\(Int(minValue))%")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("音量样式（自定义轨道）") {
                    Slider(value: $volume) {
                        Text("音量")
                    } minimumValueLabel: {
                        Image(systemName: "speaker.fill")
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    .tint(.blue)
                }
            }
            .navigationTitle("原生滑动条")
        }
    }
}

// MARK: - 页面 4：苹果原生开关

struct ToggleView: View {
    @State private var wifi = true
    @State private var bluetooth = false
    @State private var airplane = false
    @State private var green = true
    @State private var buttonStyle = false

    var body: some View {
        NavigationStack {
            List {
                Section("系统开关") {
                    Toggle("Wi-Fi", isOn: $wifi)
                    Toggle("蓝牙", isOn: $bluetooth)
                    Toggle("飞行模式", isOn: $airplane)
                    Toggle("蜂窝数据", isOn: $wifi)
                    Toggle("个人热点", isOn: $bluetooth)
                }
                Section("自定义颜色开关") {
                    Toggle("绿色开关", isOn: $green).tint(.green)
                    Toggle("红色开关", isOn: $airplane).tint(.red)
                    Toggle("蓝色开关", isOn: $bluetooth).tint(.blue)
                    Toggle("紫色开关", isOn: $wifi).tint(.purple)
                }
                Section("按钮样式开关") {
                    Toggle("按钮样式", isOn: $buttonStyle)
                        .toggleStyle(.button)
                }
                Section("带图标开关") {
                    Toggle(isOn: $wifi) {
                        Label("自动更新", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
            }
            .navigationTitle("原生开关")
        }
    }
}

// MARK: - 组件演示子页面

struct HomeView: View {
    @State private var searchText = ""
    @State private var showUpload = false
    @State private var showCloudError = false
    @State private var cloudErrorMsg = ""

    @EnvironmentObject var downloader: DownloadManager

    // 云端共享的应用信息（后台数据，所有设备可见）
    @AppStorage("appName") private var appName = "签名助手"
    @AppStorage("appDesc") private var appDesc = "签名助手是一款用苹果官方原生组件打造的签名工具，支持应用多开、证书管理、一键签名安装，全程免费、无需电脑。"
    @AppStorage("appLink") private var appLink = ""
    @AppStorage("appUploadTime") private var appUploadTime = "2026年8月19日 5:41 上传"
    @AppStorage("appIconData") private var appIconData: Data?

    /// 后台地址（隧道域名）
    private let backendBase = "https://ios.zhaisir.cn"

    var body: some View {
        NavigationStack {
            List {
                if appName.isEmpty {
                    // 链接失效删卡后的空状态
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 34))
                                .foregroundStyle(.secondary)
                            Text("暂无应用")
                                .font(.headline)
                            Text("点右上角「＋」上传应用卡片")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                } else {
                Section {
                    // 应用卡片：图标 / 名字 / 版本 / 上传时间 / 获取按钮
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 14) {
                            // 应用图标（上传过就显示上传的，否则默认）
                            if let data = appIconData, let ui = UIImage(data: data) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            } else {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 64, height: 64)
                                    .overlay(
                                        Image(systemName: "signature")
                                            .font(.system(size: 26, weight: .bold))
                                            .foregroundStyle(.white)
                                    )
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(appName)
                                    .font(.headline)
                                Text("版本 1.0.0")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(appUploadTime)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            Spacer()
                            // 获取按钮：圆角胶囊，点击直接下载 IPA 到下载页
                            Button("获取") {
                                if let url = URL(string: appLink), !appLink.isEmpty {
                                    downloader.startDownload(url: url)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .clipShape(Capsule())
                        }
                        .padding(.vertical, 10)
                        Divider()
                        Text(appDesc)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 10)
                    }
                }
                }
            }
            .searchable(text: $searchText, prompt: "搜索")
            .navigationTitle("签名助手")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showUpload = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                // 启动时从后台拉取云端共享的应用信息（不同手机装这个 App 看到同一个）
                await fetchCloudApp()
            }
            .sheet(isPresented: $showUpload) {
                UploadAppView(
                    appName: appName,
                    appDesc: appDesc,
                    appLink: appLink,
                    onSave: { name, desc, link, icon in
                        appName = name
                        appDesc = desc
                        appLink = link
                        appIconData = icon
                        appUploadTime = HomeView.currentTimeString() + " 上传"
                    }
                )
            }
            .alert("云端上传失败", isPresented: $showCloudError) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text(cloudErrorMsg)
            }
            .onChange(of: downloader.shouldRemoveCard) { _ in
                // 下载失败（链接失效）：删除卡片，并同步清空云端
                if downloader.shouldRemoveCard {
                    downloader.shouldRemoveCard = false
                    Task {
                        await removeCardAndClearCloud()
                    }
                }
            }
        }
    }

    /// 从后台拉取云端共享的应用信息
    func fetchCloudApp() async {
        guard let url = URL(string: backendBase + "/api/content") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let remote = try? JSONDecoder().decode(RemoteContent.self, from: data),
                  let app = remote.app else { return }
            appName = app.name
            appDesc = app.desc
            appLink = app.link
            appUploadTime = app.time
            if let iconB64 = app.icon, !iconB64.isEmpty, let d = Data(base64Encoded: iconB64) {
                appIconData = d
            }
        } catch {
            // 连不上后台就保留本地内容
        }
    }

    /// 链接失效：删除本地卡片并同步清空云端（其他设备也删掉）
    func removeCardAndClearCloud() async {
        appName = ""
        appDesc = ""
        appLink = ""
        appUploadTime = ""
        appIconData = nil
        _ = await pushCloudApp(name: "", desc: "", link: "", iconB64: "")
    }

    /// 推送应用信息到云端后台
    func pushCloudApp(name: String, desc: String, link: String, iconB64: String) async -> Bool {
        guard let url = URL(string: backendBase + "/api/app") else { return false }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "name": name, "desc": desc, "link": link,
            "time": HomeView.currentTimeString() + " 上传", "icon": iconB64
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            return (resp as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    /// 自动生成当前上传时间
    static func currentTimeString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日 HH:mm"
        return f.string(from: Date())
    }
}

/// 上传应用表单（点导航栏 + 弹出）——上传到云端，所有设备可见
struct UploadAppView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var desc: String
    @State private var link: String
    @State private var pickedItem: PhotosPickerItem?
    @State private var iconData: Data?
    @State private var uploading = false
    @State private var showError = false
    @State private var errorMsg = ""

    let onSave: (String, String, String, Data?) -> Void

    private let backendBase = "https://ios.zhaisir.cn"

    init(appName: String, appDesc: String, appLink: String, onSave: @escaping (String, String, String, Data?) -> Void) {
        _name = State(initialValue: appName)
        _desc = State(initialValue: appDesc)
        _link = State(initialValue: appLink)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("应用图标") {
                    PhotosPicker(selection: $pickedItem, matching: .images) {
                        HStack(spacing: 14) {
                            if let data = iconData, let ui = UIImage(data: data) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            } else {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 56, height: 56)
                                    .overlay(Image(systemName: "plus").foregroundStyle(.secondary))
                            }
                            Text("点此选择应用图标").foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: pickedItem) { item in
                        Task {
                            guard let item = item,
                                  let data = try? await item.loadTransferable(type: Data.self),
                                  let ui = UIImage(data: data) else { return }
                            let small = ui.preparingThumbnail(of: CGSize(width: 256, height: 256)) ?? ui
                            iconData = small.jpegData(compressionQuality: 0.8)
                        }
                    }
                }
                Section("应用信息") {
                    TextField("应用名字", text: $name)
                    TextField("介绍文字", text: $desc, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("IPA 链接") {
                    TextField("https://…/应用.ipa", text: $link)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    Label("不限后缀，上传时会自动检测链接里能否下载 IPA", systemImage: "link")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Section("上传时间") {
                    Text(HomeView.currentTimeString())
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("上传应用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(uploading ? "检测中…" : "上传") {
                        guard !uploading else { return }
                        uploading = true
                        let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let finalLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
                        let finalDesc = desc
                        let finalIcon = iconData
                        let time = HomeView.currentTimeString() + " 上传"
                        Task {
                            // 先验证链接里能不能下载 IPA（不只看后缀）
                            let isIPA = await verifyIPALink(finalLink)
                            guard isIPA else {
                                await MainActor.run {
                                    uploading = false
                                    errorMsg = "链接打不开，或里面不是能下载的 IPA 文件，请换一个链接"
                                    showError = true
                                }
                                return
                            }
                            let ok = await uploadToCloud(name: finalName.isEmpty ? "签名助手" : finalName,
                                                         desc: finalDesc, link: finalLink, time: time,
                                                         iconB64: finalIcon?.base64EncodedString() ?? "")
                            if ok {
                                await MainActor.run {
                                    onSave(finalName.isEmpty ? "签名助手" : finalName, finalDesc, finalLink, finalIcon)
                                    dismiss()
                                }
                            } else {
                                await MainActor.run {
                                    uploading = false
                                    errorMsg = "上传到云端失败，请检查网络后再试"
                                    showError = true
                                }
                            }
                        }
                    }
                    .disabled(link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || uploading)
                }
            }
            .alert("上传失败", isPresented: $showError) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text(errorMsg)
            }
        }
    }

    /// 验证链接内容：请求前几个字节，检测是否为 IPA（zip 格式 PK 开头），不限制后缀
    func verifyIPALink(_ urlString: String) async -> Bool {
        guard let url = URL(string: urlString) else { return false }
        var req = URLRequest(url: url)
        req.timeoutInterval = 15
        req.setValue("bytes=0-1023", forHTTPHeaderField: "Range")
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { return false }
            if http.statusCode == 200 || http.statusCode == 206 {
                // IPA 本质是 zip，开头必须是 PK
                if data.count >= 2, Array(data.prefix(2)) == [0x50, 0x4B] {
                    return true
                }
                // 兜底：Content-Type 带 ipa / zip / octet-stream
                if let ct = http.value(forHTTPHeaderField: "Content-Type")?.lowercased(),
                   ct.contains("ipa") || ct.contains("zip") || ct.contains("octet-stream") {
                    return true
                }
            }
            return false
        } catch {
            return false
        }
    }

    /// 上传到云端后台（所有设备共享）
    func uploadToCloud(name: String, desc: String, link: String, time: String, iconB64: String) async -> Bool {
        guard let url = URL(string: backendBase + "/api/app") else { return false }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "name": name, "desc": desc, "link": link, "time": time, "icon": iconB64
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode == 200 { return true }
            return false
        } catch {
            return false
        }
    }
}

// MARK: - 输入框

struct TextFieldView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var url = ""

    var body: some View {
        List {
            Section("默认输入框") {
                TextField("请输入名称", text: $name)
                TextField("邮箱地址", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            Section("圆角样式") {
                TextField("圆角边框样式", text: $name)
                    .textFieldStyle(.roundedBorder)
                TextField("带清除按钮", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
            }
            Section("安全输入（密码）") {
                SecureField("请输入密码", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            Section("键盘类型") {
                TextField("数字键盘", text: $phone)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                TextField("URL 键盘", text: $url)
                    .keyboardType(.URL)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                TextField("电话键盘", text: $phone)
                    .keyboardType(.phonePad)
                    .textFieldStyle(.roundedBorder)
                TextField("小数键盘", text: $phone)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }
            Section("自定义边框") {
                TextField("自定义圆角边框", text: $name)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            Section("当前输入内容") {
                Text("名称：\(name.isEmpty ? "（空）" : name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("邮箱：\(email.isEmpty ? "（空）" : email)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("输入框")
    }
}

// MARK: - 多行文本

struct TextEditorView: View {
    @State private var text = "这里是多行文本编辑器\n可以输入多行内容…"

    var body: some View {
        List {
            Section("TextEditor 多行输入") {
                TextEditor(text: $text)
                    .frame(height: 150)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            Section("说明") {
                Label("支持自动换行与滚动", systemImage: "text.alignleft")
                Label("可配合自定义边框使用", systemImage: "rectangle.dashed")
            }
        }
        .navigationTitle("多行文本")
    }
}

// MARK: - 选择器

struct PickerView: View {
    @State private var selection = 0
    @State private var segSelection = 1
    @State private var wheelSelection = 2

    var body: some View {
        List {
            Section("菜单样式（默认）") {
                Picker("选择颜色", selection: $selection) {
                    Text("红色").tag(0)
                    Text("绿色").tag(1)
                    Text("蓝色").tag(2)
                    Text("紫色").tag(3)
                }
            }
            Section("分段样式（Segmented）") {
                Picker("选择颜色", selection: $segSelection) {
                    Text("红").tag(0)
                    Text("绿").tag(1)
                    Text("蓝").tag(2)
                }
                .pickerStyle(.segmented)
            }
            Section("滚轮样式（Wheel）") {
                Picker("选择颜色", selection: $wheelSelection) {
                    Text("红色").tag(0)
                    Text("绿色").tag(1)
                    Text("蓝色").tag(2)
                    Text("紫色").tag(3)
                    Text("橙色").tag(4)
                }
                .pickerStyle(.wheel)
            }
            Section("当前选择") {
                Text("菜单选择：\(selection == 0 ? "红" : selection == 1 ? "绿" : selection == 2 ? "蓝" : "紫")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("选择器")
    }
}

// MARK: - 日期时间

struct DatePickerView: View {
    @State private var date = Date()
    @State private var time = Date()
    @State private var full = Date()
    @State private var compact = Date()
    @State private var wheel = Date()
    @State private var graphical = Date()

    var body: some View {
        List {
            Section("仅日期") {
                DatePicker("选择日期", selection: $date, displayedComponents: .date)
            }
            Section("仅时间") {
                DatePicker("选择时间", selection: $time, displayedComponents: .hourAndMinute)
            }
            Section("日期 + 时间") {
                DatePicker("完整日期时间", selection: $full)
            }
            Section("紧凑样式（Compact）") {
                DatePicker("紧凑模式", selection: $compact)
                    .datePickerStyle(.compact)
            }
            Section("滚轮样式（Wheel）") {
                DatePicker("滚轮模式", selection: $wheel, displayedComponents: .date)
                    .datePickerStyle(.wheel)
            }
            Section("图形样式（Graphical）") {
                DatePicker("日历模式", selection: $graphical, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
        }
        .navigationTitle("日期时间")
    }
}

// MARK: - 颜色选择

struct ColorPickerView: View {
    @State private var color = Color.blue
    @State private var color2 = Color.purple

    var body: some View {
        List {
            Section("颜色选择器") {
                ColorPicker("选择颜色", selection: $color)
                ColorPicker("支持透明度", selection: $color2, supportsOpacity: true)
            }
            Section("预览") {
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                        .frame(width: 60, height: 60)
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color2)
                        .frame(width: 60, height: 60)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("颜色选择")
    }
}

// MARK: - 步进器

struct StepperView: View {
    @State private var count = 1
    @State private var rangeCount = 5
    @State private var customCount = 0

    var body: some View {
        List {
            Section("基本步进器") {
                Stepper("数量：\(count)", value: $count, in: 1...10)
                Stepper("范围 1~20：\(rangeCount)", value: $rangeCount, in: 1...20)
            }
            Section("自定义加减按钮") {
                Stepper {
                    Text("自定义标签 数量：\(customCount)")
                } onIncrement: {
                    customCount += 1
                } onDecrement: {
                    customCount -= 1
                }
            }
            Section("当前值") {
                Text("基本：\(count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("范围：\(rangeCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("自定义：\(customCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("步进器")
    }
}

// MARK: - 进度条

struct ProgressViewPage: View {
    var body: some View {
        List {
            Section("不确定进度（加载中动画）") {
                ProgressView()
                ProgressView("加载中…")
            }
            Section("确定进度（线性）") {
                ProgressView(value: 0.3)
                ProgressView(value: 0.5).tint(.blue)
                ProgressView(value: 0.7).tint(.green)
                ProgressView(value: 0.9).tint(.red)
            }
            Section("圆形进度") {
                HStack(spacing: 40) {
                    ProgressView(value: 0.6)
                        .progressViewStyle(.circular)
                    ProgressView(value: 0.8)
                        .progressViewStyle(.circular)
                        .tint(.green)
                    ProgressView(value: 0.4)
                        .progressViewStyle(.circular)
                        .tint(.orange)
                }
                .padding(.vertical, 6)
            }
            Section("带文字说明") {
                ProgressView("下载中", value: 0.66)
                    .tint(.blue)
            }
        }
        .navigationTitle("进度条")
    }
}

// MARK: - 仪表盘（iOS 16+）

struct GaugeView: View {
    @State private var progress = 0.5

    var body: some View {
        List {
            Section("线性仪表") {
                Gauge(value: progress, in: 0...1) {
                    Text("电量")
                }
                Gauge(value: progress, in: 0...1) {
                    Text("速度")
                }
                .gaugeStyle(.linearCapacity)
                .tint(.blue)
            }
            Section("圆形仪表") {
                HStack(spacing: 30) {
                    Gauge(value: progress, in: 0...1) { }
                        .gaugeStyle(.accessoryCircular)
                        .tint(.green)
                    Gauge(value: progress, in: 0...1) { }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .tint(.orange)
                }
                .padding(.vertical, 8)
            }
            Section("滑动调整") {
                Slider(value: $progress)
                Text("当前：\(Int(progress * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("仪表盘")
    }
}

// MARK: - 文本与链接

struct TextViewPage: View {
    var body: some View {
        List {
            Section("字体大小") {
                Text("超大标题").font(.largeTitle)
                Text("标题一").font(.title)
                Text("标题二").font(.title2)
                Text("标题三").font(.title3)
                Text("正文").font(.body)
                Text("注释").font(.caption)
            }
            Section("字重与样式") {
                Text("粗体字").bold()
                Text("斜体字").italic()
                Text("下划线").underline()
                Text("删除线").strikethrough()
                Text("等宽字体").font(.system(.body, design: .monospaced))
                Text("字间距").kerning(3)
            }
            Section("颜色文字") {
                Text("蓝色文字").foregroundStyle(.blue)
                Text("红色文字").foregroundStyle(.red)
                Text("渐变文字")
                    .foregroundStyle(LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing))
            }
            Section("Label 标签") {
                Label("收藏", systemImage: "heart")
                Label("设置", systemImage: "gearshape")
                    .labelStyle(.titleAndIcon)
                Label("仅图标", systemImage: "star")
                    .labelStyle(.iconOnly)
            }
            Section("Link 链接") {
                Link("打开 Apple 官网", destination: URL(string: "https://www.apple.com")!)
                Link(destination: URL(string: "https://www.apple.com")!) {
                    Label("带图标的链接", systemImage: "safari")
                }
            }
        }
        .navigationTitle("文本与链接")
    }
}

// MARK: - 图片与图标

struct ImageViewPage: View {
    private let symbols = [
        "house.fill", "heart.fill", "star.fill", "bolt.fill",
        "cloud.sun.fill", "bell.fill", "gear", "person.fill",
        "wifi", "battery.100", "paperplane.fill", "music.note"
    ]

    var body: some View {
        List {
            Section("SF Symbols 系统图标") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    ForEach(symbols, id: \.self) { s in
                        Image(systemName: s)
                            .font(.title)
                            .foregroundStyle(.blue)
                            .frame(height: 44)
                    }
                }
                .padding(.vertical, 8)
            }
            Section("不同大小") {
                HStack(spacing: 24) {
                    Image(systemName: "star.fill").font(.caption)
                    Image(systemName: "star.fill").font(.body)
                    Image(systemName: "star.fill").font(.title)
                    Image(systemName: "star.fill").font(.largeTitle)
                    Image(systemName: "star.fill").font(.system(size: 40))
                }
                .foregroundStyle(.yellow)
                .padding(.vertical, 4)
            }
            Section("颜色与渐变") {
                HStack(spacing: 24) {
                    Image(systemName: "heart.fill").font(.title).foregroundStyle(.red)
                    Image(systemName: "leaf.fill").font(.title).foregroundStyle(.green)
                    Image(systemName: "cloud.sun.fill").font(.title)
                        .foregroundStyle(LinearGradient(colors: [.blue, .orange], startPoint: .top, endPoint: .bottom))
                }
                .padding(.vertical, 4)
            }
            Section("可缩放图片") {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue)
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.green)
            }
        }
        .navigationTitle("图片与图标")
    }
}

// MARK: - 徽标

struct BadgeViewPage: View {
    var body: some View {
        List {
            Section("数字徽标") {
                Label("消息", systemImage: "envelope").badge(5)
                Label("未接来电", systemImage: "phone").badge(12)
                Label("提醒", systemImage: "bell").badge(99)
            }
            Section("文字徽标") {
                Label("新版本", systemImage: "arrow.down.circle").badge("新")
                Label("更新", systemImage: "sparkles").badge("NEW")
            }
            Section("说明") {
                Label("红色圆点数字是 iOS 系统原生徽标", systemImage: "info.circle")
                Label("设置页和 Tab 上同样支持", systemImage: "gearshape")
            }
        }
        .navigationTitle("徽标")
    }
}

// MARK: - 列表与表单

struct ListFormViewPage: View {
    @State private var name = ""
    @State private var autoLogin = true
    @State private var date = Date()

    var body: some View {
        List {
            Section("列表分组（List + Section）") {
                Label("项目一", systemImage: "folder")
                Label("项目二", systemImage: "doc")
                Label("项目三", systemImage: "photo")
            }
            Section("带副标题的行") {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("联系人")
                        Text("副标题说明文字")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundStyle(.blue)
                }
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("群组")
                        Text("3 个成员")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "person.3.fill")
                        .foregroundStyle(.green)
                }
            }
            Section("表单（Form 同款样式）") {
                TextField("名称", text: $name)
                Toggle("自动登录", isOn: $autoLogin)
                DatePicker("生日", selection: $date, displayedComponents: .date)
            }
            Section {
                Button("保存设置") {}
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("列表与表单")
    }
}

// MARK: - 分组框

struct GroupBoxViewPage: View {
    @State private var enable = true
    @State private var autoUpdate = false

    var body: some View {
        List {
            Section("GroupBox 分组框") {
                GroupBox {
                    Toggle("启用功能", isOn: $enable)
                    Toggle("自动更新", isOn: $autoUpdate)
                } label: {
                    Label("设置", systemImage: "gearshape")
                }
                GroupBox {
                    Label("内容直接写在框内", systemImage: "info.circle")
                    Label("标题可以单独放在下方", systemImage: "textformat")
                } label: {
                    Text("说明标题").font(.caption)
                }
            }
        }
        .navigationTitle("分组框")
    }
}

// MARK: - 折叠面板

struct DisclosureGroupViewPage: View {
    @State private var expanded = true
    @State private var autoExpanded = true

    var body: some View {
        List {
            Section("可折叠面板") {
                DisclosureGroup("点击展开 / 收起") {
                    Label("隐藏内容一", systemImage: "star")
                    Label("隐藏内容二", systemImage: "heart")
                    Label("隐藏内容三", systemImage: "bolt")
                }
            }
            Section("默认展开状态") {
                DisclosureGroup("默认展开的面板", isExpanded: $expanded) {
                    Text("这里的内容默认可见")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Section("自动收起") {
                DisclosureGroup("带绑定状态的面板", isExpanded: $autoExpanded) {
                    Toggle("面板内开关", isOn: $autoExpanded)
                }
            }
        }
        .navigationTitle("折叠面板")
    }
}

// MARK: - 网格布局

struct GridViewPage: View {
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .teal, .indigo]

    var body: some View {
        List {
            Section("LazyVGrid 三列网格") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(0..<9, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colors[i].opacity(0.35))
                            .frame(height: 64)
                            .overlay(
                                Text("\(i + 1)")
                                    .font(.headline)
                                    .foregroundStyle(colors[i])
                            )
                    }
                }
                .padding(.vertical, 8)
            }
            Section("两列网格") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(0..<4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colors[i + 5].opacity(0.3))
                            .frame(height: 80)
                            .overlay(
                                Text("卡片 \(i + 1)")
                                    .font(.headline)
                                    .foregroundStyle(colors[i + 5])
                            )
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("网格布局")
    }
}

// MARK: - 弹窗与菜单

struct DialogViewPage: View {
    @State private var showAlert = false
    @State private var showConfirm = false
    @State private var showSheet = false

    var body: some View {
        List {
            Section("警告框 Alert") {
                Button("显示系统警告框") { showAlert = true }
            }
            Section("确认菜单 ConfirmationDialog") {
                Button("显示底部确认菜单") { showConfirm = true }
            }
            Section("底部弹层 Sheet") {
                Button("显示底部弹层") { showSheet = true }
            }
            Section("菜单 Menu") {
                Menu("点击打开菜单") {
                    Button("复制", systemImage: "doc.on.doc") {}
                    Button("粘贴", systemImage: "doc.on.clipboard") {}
                    Divider()
                    Menu("更多操作") {
                        Button("选项一") {}
                        Button("选项二") {}
                    }
                }
            }
            Section("长按菜单 ContextMenu") {
                Text("长按我试试")
                    .padding()
                    .contextMenu {
                        Button("复制", systemImage: "doc.on.doc") {}
                        Button("收藏", systemImage: "star") {}
                        Button("删除", systemImage: "trash", role: .destructive) {}
                    }
            }
        }
        .navigationTitle("弹窗与菜单")
        .alert("系统警告框", isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
            Button("删除", role: .destructive) {}
        } message: {
            Text("这是 iOS 原生警告框")
        }
        .confirmationDialog("确认操作", isPresented: $showConfirm, titleVisibility: .visible) {
            Button("删除", role: .destructive) {}
            Button("取消", role: .cancel) {}
        } message: {
            Text("这是底部确认菜单")
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                List {
                    Section("弹层内容") {
                        Label("从底部滑出的原生弹层", systemImage: "arrow.up.doc")
                        Label("可以包含完整页面", systemImage: "doc.richtext")
                    }
                }
                .navigationTitle("底部弹层")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") { showSheet = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - 搜索框

struct SearchableViewPage: View {
    @State private var searchText = ""
    private let products = ["iPhone", "iPhone Pro", "iPad", "iPad Pro", "MacBook Air", "MacBook Pro", "iMac", "Apple Watch", "AirPods", "Apple TV", "HomePod", "Vision Pro"]

    private var filtered: [String] {
        if searchText.isEmpty { return products }
        return products.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            Section("搜索结果（\(filtered.count) 个）") {
                ForEach(filtered, id: \.self) { item in
                    Label(item, systemImage: "apple.logo")
                }
            }
        }
        .navigationTitle("搜索框")
        .searchable(text: $searchText, prompt: "搜索 Apple 产品")
    }
}

// MARK: - 手势交互

struct GestureViewPage: View {
    @State private var tapCount = 0
    @State private var longPressed = false
    @State private var dragOffset = CGSize.zero

    var body: some View {
        List {
            Section("点击手势 Tap") {
                Text("轻点我（已点 \(tapCount) 次）")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.blue.opacity(0.15)))
                    .onTapGesture { tapCount += 1 }
            }
            Section("长按手势 Long Press") {
                Text(longPressed ? "长按成功！" : "长按我 0.5 秒")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 10).fill(longPressed ? .green.opacity(0.25) : .orange.opacity(0.15)))
                    .onLongPressGesture(minimumDuration: 0.5) {
                        longPressed = true
                    }
            }
            Section("拖拽手势 Drag") {
                VStack(spacing: 8) {
                    Image(systemName: "hand.draw.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        dragOffset = .zero
                                    }
                                }
                        )
                    Text("拖动图标试试")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("手势交互")
    }
}

// MARK: - 悬浮按钮（可拖拽，原生组件组合）

struct FloatingButtonView: View {
    @State private var position: CGPoint?
    @State private var isDragging = false
    @State private var tapCount = 0

    @ViewBuilder
    private var glassCircle: some View {
        if #available(iOS 26.0, *) {
            Circle()
                .fill(.ultraThinMaterial)
                .glassEffect()
        } else {
            Circle()
                .fill(.regularMaterial)
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                List {
                    Section("悬浮按钮（Floating Button）") {
                        Label("半空中悬浮的圆形按钮", systemImage: "circle.circle")
                        Label("按住按钮即可拖到屏幕任意位置", systemImage: "hand.draw")
                        Label("松手后停在新位置", systemImage: "pin")
                        Label("轻点按钮触发操作", systemImage: "hand.tap")
                    }
                    Section("操作记录") {
                        Label("按钮点击次数：\(tapCount)", systemImage: "number")
                    }
                    Section("说明") {
                        Label("使用官方 DragGesture 手势实现", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                        Label("材质为系统原生磨砂，iOS 26 自动液态玻璃", systemImage: "drop.fill")
                    }
                }

                Button(action: { tapCount += 1 }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .padding(22)
                        .background(glassCircle)
                        .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 1))
                        .shadow(
                            color: .black.opacity(isDragging ? 0.5 : 0.3),
                            radius: isDragging ? 16 : 8,
                            y: 6
                        )
                }
                .scaleEffect(isDragging ? 1.15 : 1.0)
                .position(position ?? CGPoint(x: geo.size.width - 70, y: geo.size.height - 140))
                .simultaneousGesture(
                    DragGesture(minimumDistance: 2)
                        .onChanged { value in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                position = value.location
                            }
                            isDragging = true
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isDragging = false
                            }
                        }
                )
            }
        }
        .navigationTitle("悬浮按钮")
    }
}

// MARK: - 后台公告（远程内容，从自己电脑上的后台拉取）

struct Announcement: Codable, Identifiable {
    var id: Int
    var title: String
    var content: String
    var time: String
    var link: String?
}

struct RemoteData: Codable {
    var app_name: String
    var announcements: [Announcement]
}

struct RemoteContentView: View {
    @State private var data: RemoteData?
    @State private var loading = true
    @State private var errorMsg: String?
    @State private var showConfig = false
    @AppStorage("remoteURL") private var remoteURL = "https://ios.zhaisir.cn"

    var body: some View {
        List {
            Section("后台连接") {
                Label("数据源：\(remoteURL)", systemImage: "link")
                Label("内容由网页后台修改后自动下发", systemImage: "arrow.down.circle")
                Label("下拉可刷新", systemImage: "arrow.clockwise")
            }
            if loading {
                Section {
                    ProgressView("正在从后台加载…")
                }
            }
            if let err = errorMsg {
                Section("加载失败") {
                    Text(err)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                    Button("重新加载") {
                        Task { await load() }
                    }
                }
            }
            if let d = data {
                Section("公告（\(d.announcements.count) 条，打开 App 自动弹出）") {
                    ForEach(d.announcements) { a in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(a.title)
                                .font(.headline)
                            Text(a.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(a.time)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle(data?.app_name ?? "后台公告")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showConfig = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showConfig) {
            RemoteConfigView(remoteURL: $remoteURL)
        }
        .refreshable {
            await load()
        }
        .task {
            await load()
        }
    }

    func load() async {
        loading = true
        errorMsg = nil
        var urlString = remoteURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString.hasSuffix("/") { urlString.removeLast() }
        // 只有地址是"基础地址"（后面没有路径）时才自动拼 /api/content
        if let u = URL(string: urlString), u.path.isEmpty || u.path == "/" {
            urlString += "/api/content"
        }
        guard let url = URL(string: urlString) else {
            errorMsg = "地址无效，请点右上角齿轮检查后台地址"
            loading = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let remote = try? JSONDecoder().decode(RemoteData.self, from: data) {
                self.data = remote
            } else if let pageText = String(data: data, encoding: .utf8) {
                // 云小店网页文本格式："公告" / 文字 / "放链接" / 链接
                let notice = parseTextNotice(pageText)
                self.data = RemoteData(
                    app_name: "云小店公告",
                    announcements: [
                        Announcement(
                            id: 1,
                            title: "公告",
                            content: notice.text,
                            time: "",
                            link: notice.link
                        )
                    ]
                )
            }
        } catch {
            errorMsg = "连接失败：\(error.localizedDescription)\n请确认：\n① 电脑上的后台已启动\n② 地址正确（电脑本机/局域网IP/飞鸽公网地址）"
        }
        loading = false
    }

    /// 解析云小店网页文本格式
    /// 支持：1) "公告" "文字" "https://链接"  2) "公告" / "文字" / "放链接"https://链接
    func parseTextNotice(_ pageText: String) -> (text: String, link: String) {
        var quotes: [String] = []
        if let regex = try? NSRegularExpression(pattern: "\"([^\"]*)\"") {
            let ns = pageText as NSString
            let results = regex.matches(in: pageText, range: NSRange(location: 0, length: ns.length))
            for m in results {
                let r = m.range(at: 1)
                if r.location != NSNotFound { quotes.append(ns.substring(with: r)) }
            }
        }
        guard let idx = quotes.firstIndex(of: "公告") else { return ("", "") }
        var text = ""
        var link = ""
        for q in quotes[(idx + 1)...] where q != "放链接" {
            if text.isEmpty { text = q } else { link = q; break }
        }
        if link.isEmpty, let range = pageText.range(of: "\"放链接\"") {
            var rest = Substring(pageText[range.upperBound...])
            rest = rest.drop(while: { $0 == " " || $0 == "\"" || $0 == "\t" })
            let candidate = rest.prefix(while: { !$0.isNewline && $0 != " " && $0 != "\"" })
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !candidate.isEmpty { link = candidate }
        }
        return (text, link)
    }
}

struct RemoteConfigView: View {
    @Binding var remoteURL: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("后台地址") {
                    TextField("http://192.168.1.100:8088", text: $remoteURL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Section("怎么填") {
                    Label("云小店/网页文本: 填页面链接，按 公告/文字/链接 解析", systemImage: "doc.text")
                    Label("默认: 隧道公告 https://ios.zhaisir.cn", systemImage: "link.badge.plus")
                    Label("电脑本机测试: http://localhost:8088", systemImage: "desktopcomputer")
                    Label("iPhone 连同一 Wi-Fi: http://电脑IP:8088", systemImage: "wifi")
                }
                Section {
                    Button("恢复默认地址（隧道公告）") {
                        remoteURL = "https://ios.zhaisir.cn"
                    }
                }
            }
            .navigationTitle("后台地址设置")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 下载页

/// 下载页底部弹窗类型
enum ActiveSheet: Identifiable {
    case share(URL)
    case export(URL)
    var id: String {
        switch self {
        case .share(let url): return "share\(url.absoluteString)"
        case .export(let url): return "export\(url.absoluteString)"
        }
    }
}

struct DownloadView: View {
    @EnvironmentObject var downloader: DownloadManager
    @State private var filter = "文件"
    @State private var actionItem: DownloadManager.DownloadItem?
    @State private var showActions = false
    @State private var activeSheet: ActiveSheet?
    @State private var showSignAlert = false
    @State private var showImporter = false
    @State private var showURLInput = false
    @State private var inputURL = ""
    @State private var showBrowser = false
    @State private var browserURL: URL?
    @StateObject private var signEngine = SignEngine()
    @State private var showSigning = false
    @State private var showSignResult = false
    @State private var signMessage = ""

    var body: some View {
        content
            .confirmationDialog("选择操作", isPresented: $showActions, titleVisibility: .visible) {
                Button("签名") { startSigning(actionItem) }
                Button("提取应用库") {
                    if let url = actionItem?.path { activeSheet = .export(url) }
                }
                Button("分享") {
                    if let url = actionItem?.path { activeSheet = .share(url) }
                }
                Button("删除", role: .destructive) {
                    if let item = actionItem { deleteItem(item) }
                }
            } message: {
                Text(actionItem?.name ?? "")
            }
            .alert("签名功能开发中", isPresented: $showSignAlert) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text("下载的 IPA 签名后会显示在「已签名」里，当前请先用全能签签名")
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .share(let url):
                    ActivityView(items: [url])
                case .export(let url):
                    DocumentExporter(url: url)
                }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item]) { result in
                if case .success(let url) = result {
                    importFile(url)
                }
            }
            .alert("网址下载", isPresented: $showURLInput) {
                TextField("https://…", text: $inputURL)
                Button("打开内置浏览器") { openBrowser() }
                Button("取消", role: .cancel) {}
            }
            .sheet(isPresented: $showBrowser) {
                if let url = browserURL {
                    WebBrowserView(startURL: url) { dl in
                        downloader.startDownload(url: dl)
                    }
                }
            }
            .overlay {
                if showSigning {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                                .controlSize(.large)
                            Text("正在签名，请稍候…")
                                .font(.headline)
                        }
                        .padding(28)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
                    }
                }
            }
            .alert("签名结果", isPresented: $showSignResult) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text(signMessage)
            }
    }

    /// 主内容：分段控件 + 列表
    private var content: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 苹果官方分段控件：文件 / 已签名
                Picker("分类", selection: $filter) {
                    Text("文件").tag("文件")
                    Text("已签名").tag("已签名")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemGroupedBackground))

                if filter == "文件" {
                    fileList
                } else {
                    signedList
                }
            }
            .navigationTitle("下载")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showImporter = true
                    } label: {
                        Label("导入", systemImage: "square.and.arrow.down")
                    }
                    Button {
                        showURLInput = true
                    } label: {
                        Label("网址下载", systemImage: "globe")
                    }
                }
            }
        }
    }

    /// 文件列表：下载中的 IPA
    private var fileList: some View {
        List {
            if downloader.items.isEmpty {
                Section {
                    Label("还没有下载任务", systemImage: "tray")
                    Text("在首页点「获取」下载 IPA，会显示在这里")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            ForEach(downloader.items) { item in
                HStack(spacing: 12) {
                    Image(systemName: iconName(for: item.state))
                        .foregroundStyle(iconColor(for: item.state))
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.name)
                            .font(.headline)
                            .lineLimit(1)
                        Text(item.state == "done" ? "已下载" : item.state == "error" ? "下载失败" : "下载中…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if item.state == "downloading" {
                        ProgressView(value: item.progress)
                            .frame(width: 60)
                    } else if item.state == "done" {
                        // 下载完成：显示红色「删除」按钮
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Text("删除")
                                .font(.subheadline)
                                .bold()
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { presentActions(for: item) }
                .padding(.vertical, 4)
            }
            if !downloader.items.isEmpty {
                Section {
                    Button(role: .destructive) {
                        withAnimation { downloader.items.removeAll() }
                    } label: {
                        Label("全部删除", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    /// 已签名列表：签名后的 IPA
    private var signedList: some View {
        Group {
            if downloader.signedItems.isEmpty {
                List {
                    Section {
                        Label("暂无已签名应用", systemImage: "checkmark.seal")
                        Text("下载的 IPA 签名后会显示在这里")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                List {
                    ForEach(downloader.signedItems) { item in
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.body)
                                Text("已签名")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                deleteItem(item)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { presentActions(for: item) }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    private func presentActions(for item: DownloadManager.DownloadItem) {
        actionItem = item
        showActions = true
    }

    private func iconName(for state: String) -> String {
        if state == "done" { return "checkmark.circle.fill" }
        if state == "error" { return "xmark.circle.fill" }
        return "arrow.down.circle"
    }

    private func iconColor(for state: String) -> Color {
        if state == "done" { return .green }
        if state == "error" { return .red }
        return .blue
    }

    private func deleteItem(_ item: DownloadManager.DownloadItem) {
        withAnimation {
            downloader.items.removeAll { $0.id == item.id }
            downloader.signedItems.removeAll { $0.id == item.id }
        }
    }

    /// 用内置证书对 IPA 签名
    private func startSigning(_ item: DownloadManager.DownloadItem?) {
        guard let item = item, let path = item.path else { return }
        guard let p12 = Bundle.main.url(forResource: "cert", withExtension: "p12"),
              let prov = Bundle.main.url(forResource: "profile", withExtension: "mobileprovision") else {
            signMessage = "内置证书未找到，请重新安装 App"
            showSignResult = true
            return
        }
        showSigning = true
        signEngine.ensureLoaded()
        Task {
            do {
                let data = try await signEngine.sign(ipaURL: path, p12URL: p12, provURL: prov, password: "iosxb.cn")
                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("Signed", isDirectory: true)
                try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                let name = (item.name as NSString).deletingPathExtension + "_已签名.ipa"
                let dest = dir.appendingPathComponent(name)
                try data.write(to: dest)
                let signed = DownloadManager.DownloadItem(name: name, url: dest, state: "done", progress: 1.0, path: dest)
                downloader.signedItems.append(signed)
                showSigning = false
                signMessage = "签名成功！已添加到「已签名」"
                showSignResult = true
                filter = "已签名"
            } catch {
                showSigning = false
                signMessage = "签名失败：\(error.localizedDescription)"
                showSignResult = true
            }
        }
    }

    /// 从文件 App 导入 IPA 到下载列表
    private func importFile(_ url: URL) {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Downloads", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let name = url.lastPathComponent
        let dest = dir.appendingPathComponent(name)
        try? FileManager.default.copyItem(at: url, to: dest)
        let item = DownloadManager.DownloadItem(name: name, url: dest, state: "done", progress: 1.0, path: dest)
        withAnimation { downloader.items.append(item) }
    }

    /// 打开内置浏览器
    private func openBrowser() {
        let t = inputURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: t), url.scheme != nil else { return }
        browserURL = url
        showBrowser = true
    }
}

// MARK: - 系统分享面板（苹果官方）
struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 导出到文件 App（提取应用库，苹果官方）
struct DocumentExporter: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        UIDocumentPickerViewController(forExporting: [url])
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

// MARK: - 内置浏览器（网址下载用，检测到 IPA 直接下载）
struct WebBrowserView: UIViewRepresentable {
    let startURL: URL
    let onDownload: (URL) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: startURL))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebBrowserView
        init(_ parent: WebBrowserView) { self.parent = parent }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                let s = url.absoluteString.lowercased()
                // 检测到 IPA 下载链接：直接下载，不弹确认
                if s.contains(".ipa") || s.contains("/download") || s.contains("download?") {
                    parent.onDownload(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}

// MARK: - 签名引擎（内置 WebView 运行 zsign-wasm 真签名）
class SignEngine: NSObject, WKScriptMessageHandler, ObservableObject {
    private var webView: WKWebView?
    private var ready = false
    private var pendingContinuation: CheckedContinuation<Data, Error>?

    func ensureLoaded() {
        guard webView == nil else { return }
        let config = WKWebViewConfiguration()
        config.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        config.userContentController.add(self, name: "signResult")
        let wv = WKWebView(frame: .zero, configuration: config)
        webView = wv
        if let url = Bundle.main.url(forResource: "sign", withExtension: "html", subdirectory: "WebSign") {
            wv.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    func sign(ipaURL: URL, p12URL: URL, provURL: URL, password: String) async throws -> Data {
        ensureLoaded()
        try await waitReady()
        let ipaB64 = try Data(contentsOf: ipaURL).base64EncodedString()
        let p12B64 = try Data(contentsOf: p12URL).base64EncodedString()
        let provB64 = try Data(contentsOf: provURL).base64EncodedString()
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
            pendingContinuation = cont
            let js = "signIpaStart('\(ipaB64)', '\(p12B64)', '\(provB64)', '\(password)')"
            webView?.evaluateJavaScript(js) { _, err in
                if let err = err {
                    cont.resume(throwing: err)
                    self.pendingContinuation = nil
                }
            }
        }
    }

    private func waitReady() async throws {
        for _ in 0..<100 {
            let ok: Bool = await withCheckedContinuation { c in
                webView?.evaluateJavaScript("typeof signIpaStart !== 'undefined'") { r, _ in
                    c.resume(returning: (r as? Bool) ?? false)
                }
            }
            if ok { ready = true; return }
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        throw NSError(domain: "SignEngine", code: -2, userInfo: [NSLocalizedDescriptionKey: "签名引擎加载超时"])
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "signResult",
              let body = message.body as? [String: Any],
              let status = body["status"] as? String else { return }
        if status == "success", let payload = body["payload"] as? String, let data = Data(base64Encoded: payload) {
            pendingContinuation?.resume(returning: data)
            pendingContinuation = nil
        } else if status == "error" {
            let msg = body["payload"] as? String ?? "签名失败"
            pendingContinuation?.resume(throwing: NSError(domain: "SignEngine", code: -1, userInfo: [NSLocalizedDescriptionKey: msg]))
            pendingContinuation = nil
        }
    }
}

// MARK: - 设置页

struct SettingsView: View {
    @AppStorage("darkMode") private var darkMode = false

    var body: some View {
        NavigationStack {
            Form {
                Section("证书") {
                    NavigationLink {
                        CertificateSettingsView()
                    } label: {
                        Label("证书管理", systemImage: "key.fill")
                    }
                }
                Section("设备") {
                    NavigationLink {
                        UDIDSettingsView()
                    } label: {
                        Label("设备 UDID", systemImage: "iphone")
                    }
                }
                Section("外观设置") {
                    Toggle("深色模式", isOn: $darkMode)
                        .tint(.blue)
                }
            }
            .navigationTitle("设置")
        }
    }
}

/// 证书管理：内置证书，无需手动导入
struct CertificateSettingsView: View {
    private var certInstalled: Bool {
        Bundle.main.url(forResource: "cert", withExtension: "p12") != nil
    }
    private var profileInstalled: Bool {
        Bundle.main.url(forResource: "profile", withExtension: "mobileprovision") != nil
    }

    var body: some View {
        Form {
            Section("内置证书") {
                Label(certInstalled ? "已内置企业证书 (P12)" : "证书未找到",
                      systemImage: certInstalled ? "checkmark.seal.fill" : "xmark.circle")
                    .foregroundStyle(certInstalled ? .green : .red)
                Label(profileInstalled ? "已内置签名描述文件" : "描述文件未找到",
                      systemImage: profileInstalled ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(profileInstalled ? .green : .red)
                Text("北京西贝 企业证书，签名时自动使用，无需手动导入")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("证书管理")
    }
}

/// 设备 UDID：安装描述文件自动获取
struct UDIDSettingsView: View {
    @AppStorage("remoteURL") private var remoteURL = "https://ios.zhaisir.cn"
    @State private var udid = ""

    var body: some View {
        Form {
            Section {
                Button {
                    if let url = URL(string: remoteURL + "/udid.mobileconfig") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("安装描述文件获取 UDID", systemImage: "arrow.down.doc.fill")
                }
            } footer: {
                Text("在 Safari 中打开并安装描述文件，安装完成后自动返回本 App")
            }
            Section("当前设备 UDID") {
                if udid.isEmpty {
                    Text("安装描述文件后自动显示")
                        .foregroundStyle(.secondary)
                } else {
                    Text(udid)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle("设备 UDID")
        .task { await fetchUDID() }
    }

    func fetchUDID() async {
        guard let url = URL(string: remoteURL + "/udid_list.json") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let obj = try? JSONSerialization.jsonObject(with: data) {
                if let arr = obj as? [[String: Any]], let last = arr.last, let u = last["udid"] as? String {
                    udid = u
                } else if let dict = obj as? [String: Any] {
                    if let arr = dict["devices"] as? [[String: Any]], let last = arr.last, let u = last["udid"] as? String {
                        udid = u
                    } else if let u = dict["udid"] as? String {
                        udid = u
                    }
                }
            }
        } catch {
        }
    }
}

#Preview {
    ContentView()
}
