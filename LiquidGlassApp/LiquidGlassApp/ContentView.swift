import SwiftUI

// ============================================================
//  LiquidGlass 签名工具 —— SwiftUI 原生版
//
//  · 底部导航栏：TabView（iOS 系统原生 TabBar）
//  · 四个标签：应用 / 签名 / 文件 / 设置
//  · 全部使用系统原生组件（List、Form、Toggle、Picker、
//    ProgressView、Alert 等），iOS 26 自动呈现液态玻璃材质，
//    旧系统自动回退原生磨砂，无需任何判断代码
// ============================================================

struct ContentView: View {
    var body: some View {
        TabView {
            AppsView()
                .tabItem { Label("应用", systemImage: "app") }
            SignView()
                .tabItem { Label("签名", systemImage: "signature") }
            FilesView()
                .tabItem { Label("文件", systemImage: "folder") }
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
    }
}

// MARK: - 应用页

struct AppsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("我的应用") {
                    AppRow(
                        icon: "sparkles",
                        color: .blue,
                        name: "LiquidGlass App",
                        desc: "v1.0.0 · com.example.liquidglass",
                        badge: "已签名",
                        badgeColor: .green
                    )
                    AppRow(
                        icon: "gamecontroller.fill",
                        color: .yellow,
                        name: "示例游戏",
                        desc: "v2.3.1 · 7 天有效期",
                        badge: "待续签",
                        badgeColor: .orange
                    )
                    AppRow(
                        icon: "hammer.fill",
                        color: .cyan,
                        name: "示例工具",
                        desc: "v1.2.0 · 未安装",
                        badge: nil,
                        badgeColor: nil
                    )
                }
                Section("签名历史") {
                    HistoryRow(desc: "2026-09-22 14:32 · LiquidGlass App 签名成功", ok: true)
                    HistoryRow(desc: "2026-09-20 09:15 · 示例游戏 签名失败", ok: false)
                }
                if #available(iOS 26.0, *) {
                    Section("液态玻璃演示") {
                        Label("iOS 26 系统原生液态玻璃材质", systemImage: "drop.fill")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect()
                    }
                }
            }
            .navigationTitle("应用")
        }
    }
}

struct AppRow: View {
    let icon: String
    let color: Color
    let name: String
    let desc: String
    let badge: String?
    let badgeColor: Color?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(colors: [color.opacity(0.7), color.opacity(0.4)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 10)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.body)
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if let badge, let badgeColor {
                Text(badge)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(badgeColor.opacity(0.18), in: Capsule())
                    .foregroundStyle(badgeColor)
            }
        }
        .padding(.vertical, 2)
    }
}

struct HistoryRow: View {
    let desc: String
    let ok: Bool

    var body: some View {
        HStack {
            Text(desc).font(.subheadline)
            Spacer()
            Text(ok ? "成功" : "失败")
                .font(.caption.bold())
                .foregroundStyle(ok ? .green : .orange)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - 签名页

struct SignView: View {
    @State private var cert = "Apple ID 自签（免费 · 7 天）"
    @State private var appName = "LiquidGlass App"
    @State private var bundleID = "com.example.liquidglass"
    @State private var version = "1.0.0 (1)"
    @State private var antiDebug = true
    @State private var injectPlugin = false
    @State private var progress: Double = 0
    @State private var signing = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                Section("证书") {
                    RowPicker(label: "签名证书", value: cert)
                    RowPicker(label: "描述文件", value: "自动选择")
                }
                Section("应用信息") {
                    TextField("应用名称", text: $appName)
                    TextField("Bundle ID", text: $bundleID)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled()
                    TextField("版本号", text: $version)
                }
                Section("签名选项") {
                    Toggle("启用反调试", isOn: $antiDebug)
                    Toggle("注入插件", isOn: $injectPlugin)
                }
                Section {
                    Button {
                        startSign()
                    } label: {
                        Text("开始签名")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(signing)

                    if signing {
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                        Text("正在签名 \(Int(progress * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("签名")
            .alert("签名成功", isPresented: $showSuccess) {
                Button("完成", role: .cancel) {}
            } message: {
                Text("LiquidGlass App 已签名完成\n有效期 7 天 · 可立即安装")
            }
        }
    }

    private func startSign() {
        signing = true
        progress = 0
        // 模拟签名进度（真实签名逻辑需在真机环境下处理证书与 Mach-O 重签名）
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            progress += Double.random(in: 0.04...0.12)
            if progress >= 1.0 {
                progress = 1.0
                timer.invalidate()
                signing = false
                showSuccess = true
            }
        }
    }
}

struct RowPicker: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - 文件页

struct FilesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("IPA 文件") {
                    FileRow(icon: "doc.zipper", color: .orange, name: "LiquidGlassApp.ipa", desc: "21 KB · 刚刚")
                    FileRow(icon: "doc.zipper", color: .green, name: "ExampleGame.ipa", desc: "88 MB · 昨天")
                    FileRow(icon: "doc.zipper", color: .purple, name: "ToolBox.ipa", desc: "12 MB · 3 天前")
                }
            }
            .navigationTitle("文件")
        }
    }
}

struct FileRow: View {
    let icon: String
    let color: Color
    let name: String
    let desc: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.body)
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - 设置页

struct SettingsView: View {
    @State private var autoRenew = true
    @State private var darkMode = true

    var body: some View {
        NavigationStack {
            Form {
                Section("通用") {
                    Toggle("自动续签提醒", isOn: $autoRenew)
                    Toggle("深色模式", isOn: $darkMode)
                }
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("v1.0.0").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("开源协议")
                        Spacer()
                        Text("仅供学习交流").foregroundStyle(.secondary)
                    }
                }
                Section("Liquid Glass") {
                    Label("iOS 26 自动启用液态玻璃 · 旧系统原生磨砂", systemImage: "drop")
                        .font(.footnote)
                }
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    ContentView()
}
