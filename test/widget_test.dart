// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:bol_il_bwa/main.dart';

void main() {
  testWidgets('앱 시작 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const BolIlBwaApp());

    // 앱 제목 확인
    expect(find.text('볼일봐'), findsOneWidget);
  });
}
