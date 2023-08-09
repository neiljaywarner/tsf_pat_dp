import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter', (tester) async {
      // Load app widget.
      // or main as app.main()
      await tester.pumpWidget(DevicePreview(
        enabled: true,
        builder: (context) => MyMiniApp(), // Wrap your app
      ));

      await tester.pumpAndSettle();

      Element element = find.text('HELLO').evaluate().first;
      double? aspectRatio1 = element.size?.aspectRatio;
      double? width1 = element.size?.width;
      debugPrint('ar1=$aspectRatio1;w1=$width1');

      //note: (element.widget as Text).textScaleFactor and .style?.fontSize were both null
      await tester.tap(find.text('Device Preview'));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.drag(find.text('Frame visibility'), const Offset(0, -800));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      // not sure why drag till visible didn't work

      expect(find.text('Text scaling factor'), findsOneWidget);

      expect(find.text('1.0'), findsOneWidget);

      bool found2Dot = false;
      double i = 50.0;
      while (!found2Dot) {
        await tester.slideToValue(find.byType(Slider, skipOffstage: false), i);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        try {
          expect(find.text('2.0'), findsOneWidget);
          found2Dot = true;
        } catch (e) {
          found2Dot = false;
        }
        i = i + 5.0;
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      Element element2 = find.text('HELLO').evaluate().first;
      double? aspectRatio2 = element2.size?.aspectRatio;
      double? width2 = element2.size?.width;
      debugPrint('ar2=$aspectRatio2;w2=$width2');

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

class MyMiniApp extends StatelessWidget {
  const MyMiniApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(77),
            child: const Text(
              'HELLO',
              style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ),
        ),
      );
}
