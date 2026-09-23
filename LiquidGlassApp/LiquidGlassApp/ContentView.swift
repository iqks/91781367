import SwiftUI

// ============================================================
//  官方风格底部导航栏 + 液态玻璃（SwiftUI 原生）
//
//  · 底部导航栏：TabView —— iOS 系统原生 TabBar 组件，
//    iOS 26 及以上系统自动呈现「液态玻璃」材质，旧系统自动传统磨砂
//  · 顶部导航栏：NavigationStack —— 系统原生导航栏，同样自动适配
//  · 无需任何判断代码：系统支持液态玻璃就自动用，不支持就自动原生
// ============================================================

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house")
                }
            FeatureView()
                .tabItem {
                    Label("功能", systemImage: "square.stack")
                }
            ShareView()
                .tabItem {
                    Label("分享", systemImage: "arrowshape.turn.up.right")
                }
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}

// MARK: - 首页

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("液态玻璃说明") {
                    Label("iOS 26 及以上：系统自动启用液态玻璃", systemImage: "sparkles")
                    Label("旧系统：自动回退传统磨砂材质", systemImage: "circle.lefthalf.filled")
                }
                Section("自定义玻璃效果演示") {
                    GlassDemoRow(title: "液态玻璃卡片", systemImage: "globe")
                }
            }
            .navigationTitle("首页")
        }
    }
}

// MARK: - 功能

struct FeatureView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("功能页面内容", systemImage: "square.stack.3d.up")
                }
            }
            .navigationTitle("功能")
        }
    }
}

// MARK: - 分享

struct ShareView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("分享页面内容", systemImage: "paperplane")
                }
            }
            .navigationTitle("分享")
        }
    }
}

// MARK: - 设置

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("设置页面内容", systemImage: "gearshape.2")
                }
            }
            .navigationTitle("设置")
        }
    }
}

// MARK: - 自定义液态玻璃演示行
//  iOS 26+ 使用真液态玻璃（.glassEffect）；旧系统自动回退磨砂圆角卡片

struct GlassDemoRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        if #available(iOS 26.0, *) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect()
        } else {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    ContentView()
}
