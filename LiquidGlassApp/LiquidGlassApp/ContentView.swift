import SwiftUI

// ============================================================
//  苹果官方组件展示 App —— SwiftUI 原生版
//
//  · 底部导航栏：TabView（iOS 系统原生 TabBar，App Store 同款）
//  · 多个页面，每页展示一种苹果官方原生组件：
//    导航栏 / 按钮 / 滑动条 / 开关 / 输入框 / 更多组件
//  · 全部使用系统原生组件，iOS 26 自动呈现液态玻璃材质，
//    旧系统自动回退原生磨砂，无需任何判断代码
// ============================================================

struct ContentView: View {
    var body: some View {
        TabView {
            TabBarView()
                .tabItem { Label("导航栏", systemImage: "rectangle.bottomthird.inset.filled") }
            ButtonView()
                .tabItem { Label("按钮", systemImage: "button.programmable") }
            SliderView()
                .tabItem { Label("滑动条", systemImage: "slider.horizontal.3") }
            ToggleView()
                .tabItem { Label("开关", systemImage: "switch.2") }
            TextFieldView()
                .tabItem { Label("输入框", systemImage: "text.cursor") }
            MoreView()
                .tabItem { Label("更多", systemImage: "square.grid.2x2") }
        }
    }
}

// MARK: - 页面 1：底部导航栏（当前页就是官方 TabBar 本身）

struct TabBarView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("这就是苹果官方底部导航栏（TabView / UITabBar）", systemImage: "rectangle.bottomthird.inset.filled")
                    Label("iOS 26 自动启用液态玻璃材质", systemImage: "drop.fill")
                    Label("旧系统自动回退原生磨砂", systemImage: "circle.lefthalf.filled")
                    Label("点击下方标签即可切换页面", systemImage: "hand.tap")
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
                        Label("分享按钮", systemImage: "square.and.arrow.up")
                    }
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
                }
                Section("大按钮") {
                    Button("全宽蓝色大按钮") {}
                        .buttonStyle(.borderedProminent)
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

    var body: some View {
        NavigationStack {
            List {
                Section("基本滑动条") {
                    Slider(value: $value)
                    Text("当前值：\(value, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("蓝色滑动条（系统强调色）") {
                    Slider(value: $value)
                        .tint(.blue)
                }
                Section("步进滑动条（每次 +1）") {
                    Slider(value: $stepValue, in: 0...10, step: 1)
                    Text("当前：\(Int(stepValue))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("带范围滑动条（0 ~ 100）") {
                    Slider(value: $minValue, in: 0...100)
                    Text("当前：\(Int(minValue))%")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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

    var body: some View {
        NavigationStack {
            List {
                Section("系统开关") {
                    Toggle("Wi-Fi", isOn: $wifi)
                    Toggle("蓝牙", isOn: $bluetooth)
                    Toggle("飞行模式", isOn: $airplane)
                }
                Section("自定义颜色开关") {
                    Toggle("绿色开关", isOn: $green)
                        .tint(.green)
                }
            }
            .navigationTitle("原生开关")
        }
    }
}

// MARK: - 页面 5：苹果原生输入框

struct TextFieldView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            List {
                Section("输入框") {
                    TextField("请输入名称", text: $name)
                        .textFieldStyle(.roundedBorder)
                    TextField("邮箱地址", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }
                Section("安全输入（密码）") {
                    SecureField("请输入密码", text: $password)
                        .textFieldStyle(.roundedBorder)
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
            .navigationTitle("原生输入框")
        }
    }
}

// MARK: - 页面 6：更多官方组件

struct MoreView: View {
    @State private var selection = 0
    @State private var count = 1
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            List {
                Section("选择器（Picker）") {
                    Picker("选择颜色", selection: $selection) {
                        Text("红色").tag(0)
                        Text("绿色").tag(1)
                        Text("蓝色").tag(2)
                    }
                }
                Section("步进器（Stepper）") {
                    Stepper("数量：\(count)", value: $count, in: 1...10)
                }
                Section("进度条（ProgressView）") {
                    ProgressView(value: 0.7)
                    Text("加载进度 70%")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("日期选择器（DatePicker）") {
                    DatePicker("选择日期", selection: $date, displayedComponents: .date)
                    DatePicker("选择时间", selection: $date, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("更多组件")
        }
    }
}

#Preview {
    ContentView()
}
