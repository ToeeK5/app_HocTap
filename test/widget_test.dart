import 'package:flutter_test/flutter_test.dart';

import 'package:app_hoctap/main.dart';

void main() {
  testWidgets('Hien thi man hinh dang nhap', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('QUẢN LÝ HỌC TẬP'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
  });
}
