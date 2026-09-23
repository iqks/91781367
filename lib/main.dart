import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const LiquidGlassApp());
}

/// ============================================================
///  iOS 原生风格导航栏 Demo（Cupertino 风格）
///
///  规则（对应你的需求）：
///   - iOS 26 及以上 → 模拟液态玻璃（更通透的毛玻璃）
///   - iOS 25 及以下 → 传统原生磨砂导航栏
///   - 全部使用 Flutter 自带 Cupertino 组件，不依赖任何第三方插件，
///     在 GitHub Actions 打包 iOS 未签名 IPA 100% 稳定
/// ============================================================
class LiquidGlassApp extends StatelessWidget {
  const LiquidGlassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '液态玻璃 Demo',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: const HomePage(),
    );
  }
}

/// 判断当前设备系统版本是否支持原生液态玻璃（iOS 26+）
bool supportLiquidGlass() {
  // Web / 桌面预览时直接返回 false，避免 dart:io 平台异常
  if (kIsWeb) return false;
  if (!Platform.isIOS) return false;
  final major =
      int.tryParse(Platform.operatingSystemVersion.split('.').first) ?? 0;
  return major >= 26;
}

/// 根据系统版本返回导航栏背景色：
/// iOS 26+ → 更通透（视觉上模拟液态玻璃）
/// 旧系统 → 传统磨砂毛玻璃
Color navBarBackground(BuildContext context) {
  final isLiquid = supportLiquidGlass();
  final color = isLiquid
      ? CupertinoColors.systemGrey.withValues(alpha: 0.55)
      : CupertinoColors.systemGrey.withValues(alpha: 0.78);
  return CupertinoDynamicColor.resolve(color, context);
}

/// 显示当前 iOS 版本与玻璃模式的提示文案
String glassModeText(BuildContext context) {
  if (kIsWeb) {
    return '当前平台：Web 预览模式\n打包安装到 iPhone 后自动生效';
  }
  if (!Platform.isIOS) {
    return '当前平台：非 iOS（预览模式）\n打包安装到 iPhone 后自动生效';
  }
  final version = Platform.operatingSystemVersion;
  final isLiquid = supportLiquidGlass();
  return 'iOS 版本：$version\n'
      '玻璃模式：${isLiquid ? '液态玻璃（iOS 26+ 通透模式）' : '传统原生磨砂'}';
}

/// 首页：普通导航栏 + 列表入口
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('首页'),
        // 背景色：自动适配液态玻璃 / 传统磨砂
        backgroundColor: navBarBackground(context),
        // 去掉底部分割线，更贴近 iOS 原生
        border: null,
      ),
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '导航栏已自动适配系统版本',
              style: TextStyle(fontSize: 15, color: CupertinoColors.secondaryLabel),
            ),
          ),
          _buildCell(
            context,
            title: '普通导航栏（推入详情页）',
            subtitle: '自带返回箭头 + 侧滑返回手势',
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const DetailPage()),
            ),
          ),
          _buildCell(
            context,
            title: '大标题导航栏（滚动收缩）',
            subtitle: 'CupertinoSliverNavigationBar',
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const LargeTitlePage()),
            ),
          ),
          _buildCell(
            context,
            title: '关于本 Demo',
            subtitle: glassModeText(context),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
      ),
      child: CupertinoListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(CupertinoIcons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// 详情页：普通导航栏（推入式，系统自带返回按钮）
class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('详情页面'),
        backgroundColor: navBarBackground(context),
        border: null,
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.sparkles, size: 56),
              const SizedBox(height: 12),
              const Text('内容区域', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  glassModeText(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 大标题导航栏页面：滚动时大标题自动收缩为小标题
class LargeTitlePage extends StatelessWidget {
  const LargeTitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('大标题'),
            // 大标题导航栏同样自动适配液态玻璃
            backgroundColor: navBarBackground(context),
            border: null,
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                List.generate(
                  20,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      '第 ${i + 1} 行内容 · 滚动试试大标题收缩效果',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
