import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const LiquidGlassApp());
}

/// ============================================================
///  iOS 原生风格 App Demo（Cupertino 组件）
///
///  结构：打开 App 就是「底部导航栏 + 各标签页」
///  - 底部导航栏：CupertinoTabBar（iOS 原生底部标签栏，自带毛玻璃）
///  - 每个标签页：顶部 CupertinoNavigationBar + 简单内容
///  - 液态玻璃规则：iOS 26+ 更通透（模拟液态玻璃）；旧系统传统磨砂
///  - 全部 Flutter 自带 Cupertino 组件，GitHub Actions 打包稳定
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

/// 主页面：iOS 原生底部标签导航栏（CupertinoTabBar）
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
            icon: Icon(CupertinoIcons.search),
            label: '搜索',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: '我的',
          ),
        ],
        // 底部导航栏毛玻璃背景，自动适配液态玻璃
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
            return const _SearchTab();
          default:
            return const _ProfileTab();
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.house_fill, size: 48),
                const SizedBox(height: 12),
                const Text('首页内容', style: TextStyle(fontSize: 18)),
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
          ),
        );
      },
    );
  }
}

/// 标签页 2：搜索
class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('搜索'),
            backgroundColor: navBarBackground(context),
            border: null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.search, size: 48),
                const SizedBox(height: 12),
                const Text('搜索内容', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 标签页 3：我的
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('我的'),
            backgroundColor: navBarBackground(context),
            border: null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.person_fill, size: 48),
                const SizedBox(height: 12),
                const Text('我的内容', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }
}
