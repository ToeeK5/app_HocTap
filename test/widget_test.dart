import 'package:flutter_test/flutter_test.dart';

import 'package:app_hoctap/main.dart';

void main() {
  testWidgets('Hien thi man hinh dang nhap', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('QUAN LY HOC TAP'), findsOneWidget);
    expect(find.text('DANG NHAP'), findsOneWidget);
  });
}
