import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const LiquidGlassApp());
}

/// ============================================================
///  iOS 原生风格 App Demo（Cupertino 组件）
///
///  结构：打开 App 就是「官方风格底部导航栏 + 各标签页」
///  - 底部导航栏：CupertinoTabBar
///    （Flutter 官方对 iOS 系统 UITabBar 的实现，
///      即 App Store 那种底部栏：半透明磨砂、图标+文字）
///  - 4 个标签：首页 / 功能 / 分享 / 设置
///  - 每个标签页：顶部 CupertinoNavigationBar（液态玻璃）+ 内容
///  - 液态玻璃规则：iOS 26+ 更通透；旧系统传统磨砂
///  - 纯 Flutter 自带 Cupertino 组件，GitHub Actions 打包稳定
/// ============================================================
class LiquidGlassApp extends StatelessWidget {
  const LiquidGlassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '液态玻璃 Demo',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: const MainTabPage(),
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

/// 根据系统版本返回玻璃背景色：
/// iOS 26+ → 更通透（视觉上模拟液态玻璃）；旧系统 → 传统磨砂
Color navBarBackground(BuildContext context) {
  final isLiquid = supportLiquidGlass();
  final color = isLiquid
      ? CupertinoColors.systemGrey.withValues(alpha: 0.55)
      : CupertinoColors.systemGrey.withValues(alpha: 0.78);
  return CupertinoDynamicColor.resolve(color, context);
}

/// 主页面：官方风格底部标签导航栏（CupertinoTabBar）
class MainTabPage extends StatelessWidget {
  const MainTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_stack_3d),
            label: '功能',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.arrowshape_turn_up_right),
            label: '分享',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            label: '设置',
          ),
        ],
        // 底部导航栏半透明毛玻璃背景，自动适配液态玻璃
        backgroundColor: navBarBackground(context),
        // 去掉顶部分隔线，更贴近 iOS 原生
        border: null,
      ),
      tabBuilder: (context, index) {
        // 每个标签页独立的导航栈（和 iOS 原生一致）
        switch (index) {
          case 0:
            return const _HomeTab();
          case 1:
            return const _FeatureTab();
          case 2:
            return const _ShareTab();
          default:
            return const _SettingsTab();
        }
      },
    );
  }
}

/// 标签页 1：首页
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('首页'),
            backgroundColor: navBarBackground(context),
            border: null,
          ),
          child: const _EmptyContent(icon: CupertinoIcons.house_fill),
        );
      },
    );
  }
}

/// 标签页 2：功能
class _FeatureTab extends StatelessWidget {
  const _FeatureTab();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('功能'),
            backgroundColor: navBarBackground(context),
            border: null,
          ),
          child: const _EmptyContent(icon: CupertinoIcons.square_stack_3d_fill),
        );
      },
    );
  }
}

/// 标签页 3：分享
class _ShareTab extends StatelessWidget {
  const _ShareTab();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('分享'),
            backgroundColor: navBarBackground(context),
            border: null,
          ),
          child: const _EmptyContent(
            icon: CupertinoIcons.arrowshape_turn_up_right_fill,
          ),
        );
      },
    );
  }
}

/// 标签页 4：设置
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('设置'),
            backgroundColor: navBarBackground(context),
            border: null,
          ),
          child: const _EmptyContent(icon: CupertinoIcons.gear_alt_fill),
        );
      },
    );
  }
}

/// 简单的标签页内容占位
class _EmptyContent extends StatelessWidget {
  const _EmptyContent({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: CupertinoColors.systemBlue),
          const SizedBox(height: 12),
          const Text('页面内容', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            supportLiquidGlass() ? '液态玻璃模式' : '传统磨砂模式',
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
