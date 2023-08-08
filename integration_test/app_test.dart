import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tsf_pat_dp/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter', (tester) async {
      // Load app widget.
      // or main as app.main()
      await tester.pumpWidget(DevicePreview(
        enabled: true,
        builder: (context) => MyApp(), // Wrap your app
      ));

      // Verify the counter starts at 0.
      expect(find.text('0'), findsOneWidget);

      // Finds the floating action button to tap on.
      final Finder fab = find.byTooltip('Increment');

      // Emulate a tap on the floating action button.
      await tester.tap(fab);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify the counter increments by 1.
      expect(find.text('1'), findsOneWidget);
      double textWidth = find.text('1').evaluate().first.size?.width ?? 0;
      debugPrint('textWidth=** $textWidth');
      await tester.tap(find.text('Device Preview'));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.drag(find.text('Frame visibility'), const Offset(0, -800));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      //
      // await tester.drag(find.text('Accessible navigation'), const Offset(0, -200));
      // await tester.pumpAndSettle(const Duration(milliseconds: 200));
      //
      // await tester.drag(find.text('Bold text'), const Offset(0, -200));
      // await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(find.text('Text scaling factor'), findsOneWidget);

      /*
      await tester.dragUntilVisible(
          find.text('Locale'), find.text('Text Scaling factor', skipOffstage: false), Offset(0, -100));
     */
      expect(find.text('1.0'), findsOneWidget);

      await tester.slideToValue(find.byType(Slider, skipOffstage: false), 65);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('2.0'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      textWidth = find.text('1').evaluate().first.size?.width ?? 0;
      debugPrint('textWidth=** $textWidth');

      // could confirm the you have pressed not visibile before scale 2
      // and visible adter
    });
  });
}

extension SlideTo on WidgetTester {
  Future<void> slideToValue(Finder slider, double value, {double paddingOffset = 24.0}) async {
    final zeroPoint = this.getTopLeft(slider) + Offset(paddingOffset, this.getSize(slider).height / 2);
    final totalWidth = this.getSize(slider).width - (2 * paddingOffset);
    final calculatdOffset = value * (totalWidth / 100);
    await this.dragFrom(zeroPoint, Offset(calculatdOffset, 0));
  }
}
