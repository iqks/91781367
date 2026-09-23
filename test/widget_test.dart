// 基础 Widget 冒烟测试：验证应用能正常构建
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_glass_app/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    // 构建应用并触发一帧
    await tester.pumpWidget(const LiquidGlassApp());

    // 验证首页导航栏标题正常显示
    expect(find.text('首页'), findsOneWidget);
  });
}
