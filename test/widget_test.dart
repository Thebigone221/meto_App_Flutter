import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meteo_app/main.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherApp());
    await tester.pumpAndSettle();

    expect(find.text('Météo Sénégal'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });
}
