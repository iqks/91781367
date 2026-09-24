import SwiftUI

// ============================================================
//  苹果官方组件大全 App —— SwiftUI 原生版
//
//  · 底部导航栏：TabView（系统原生 TabBar，App Store 同款）
//  · 5 个主页面 + 组件大全二级导航（17 个子页面）
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
            AllComponentsView()
                .tabItem { Label("组件大全", systemImage: "square.grid.3x3") }
        }
    }
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

// MARK: - 页面 5：组件大全（二级导航）

struct AllComponentsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("输入类") {
                    NavigationLink("输入框 TextField", destination: TextFieldView())
                    NavigationLink("多行文本 TextEditor", destination: TextEditorView())
                }
                Section("选择类") {
                    NavigationLink("选择器 Picker", destination: PickerView())
                    NavigationLink("日期时间 DatePicker", destination: DatePickerView())
                    NavigationLink("颜色选择 ColorPicker", destination: ColorPickerView())
                }
                Section("数值类") {
                    NavigationLink("步进器 Stepper", destination: StepperView())
                    NavigationLink("进度条 ProgressView", destination: ProgressViewPage())
                    NavigationLink("仪表盘 Gauge", destination: GaugeView())
                }
                Section("展示类") {
                    NavigationLink("文本与链接 Text/Link", destination: TextViewPage())
                    NavigationLink("图片与图标 Image", destination: ImageViewPage())
                    NavigationLink("徽标 Badge", destination: BadgeViewPage())
                }
                Section("容器类") {
                    NavigationLink("列表与表单 List/Form", destination: ListFormViewPage())
                    NavigationLink("分组框 GroupBox", destination: GroupBoxViewPage())
                    NavigationLink("折叠面板 DisclosureGroup", destination: DisclosureGroupViewPage())
                    NavigationLink("网格布局 Grid", destination: GridViewPage())
                }
                Section("交互类") {
                    NavigationLink("弹窗与菜单 Alert/Menu", destination: DialogViewPage())
                    NavigationLink("搜索框 Searchable", destination: SearchableViewPage())
                    NavigationLink("手势交互 Gesture", destination: GestureViewPage())
                    NavigationLink("悬浮按钮 FloatingButton", destination: FloatingButtonView())
                }
                Section("后台") {
                    NavigationLink("后台公告 RemoteContent", destination: RemoteContentView())
                }
            }
            .navigationTitle("组件大全")
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
}

struct RemoteData: Codable {
    var app_name: String
    var welcome: String
    var announcements: [Announcement]
}

struct RemoteContentView: View {
    @State private var data: RemoteData?
    @State private var loading = true
    @State private var errorMsg: String?
    @State private var showConfig = false
    @AppStorage("remoteURL") private var remoteURL = "http://localhost:8088"

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
                Section("欢迎语") {
                    Text(d.welcome)
                        .font(.headline)
                }
                Section("公告（\(d.announcements.count) 条）") {
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
        if !urlString.contains("/api/content") {
            urlString += "/api/content"
        }
        guard let url = URL(string: urlString) else {
            errorMsg = "地址无效，请点右上角齿轮检查后台地址"
            loading = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.data = try JSONDecoder().decode(RemoteData.self, from: data)
        } catch {
            errorMsg = "连接失败：\(error.localizedDescription)\n请确认：\n① 电脑上的后台已启动\n② 地址正确（电脑本机/局域网IP/飞鸽公网地址）"
        }
        loading = false
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
                    Label("电脑本机测试: http://localhost:8088", systemImage: "desktopcomputer")
                    Label("iPhone 连同一 Wi-Fi: http://电脑IP:8088", systemImage: "wifi")
                    Label("外网（飞鸽穿透）: http://xxxx.fgnb.top", systemImage: "globe")
                }
                Section {
                    Button("恢复默认地址") {
                        remoteURL = "http://localhost:8088"
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

#Preview {
    ContentView()
}
