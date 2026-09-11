import 'package:flutter_test/flutter_test.dart';
import 'package:radio_channel/main.dart';

void main() {
  testWidgets('RadioChannelApp boots up smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RadioChannelApp());
    expect(find.text('FALAH RADIO'), findsOneWidget);
  });
}
