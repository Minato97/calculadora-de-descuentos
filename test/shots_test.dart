// SHOTS=1 flutter test test/shots_test.dart  -> store/screenshot_N.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:calc_descuentos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _font(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

void main() {
  final enabled = Platform.environment['SHOTS'] == '1';
  testWidgets('capturas', skip: !enabled, (tester) async {
    final sdk = Platform.environment['FLUTTER_ROOT'] ??
        File(Platform.resolvedExecutable).parent.parent.parent.parent.path;
    final fonts = '$sdk/bin/cache/artifacts/material_fonts';
    await _font('Roboto', '$fonts/roboto-regular.ttf');
    await _font('Roboto', '$fonts/roboto-bold.ttf');
    await _font('MaterialIcons', '$fonts/materialicons-regular.otf');

    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
    tester.view.devicePixelRatio = 2.625;
    tester.view.physicalSize = const Size(1080, 2160);
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    Future<void> save(String name) async {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.625);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('store/$name').writeAsBytesSync(data!.buffer.asUint8List());
      });
    }

    Widget app(int tab) => RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorSchemeSeed: const Color(0xFFEF4444),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            home: HomePage(showAds: false, tab: tab),
          ),
        );

    Future<void> go(Widget w) async {
      await tester.pumpWidget(w);
      await tester.pump(const Duration(milliseconds: 300));
    }

    await go(app(0));
    await save('screenshot_1.png');

    await tester.enterText(find.byType(TextField).first, '2499');
    await tester.enterText(find.byType(TextField).at(1), '40');
    await tester.enterText(find.byType(TextField).at(2), '15');
    await tester.pump(const Duration(milliseconds: 300));
    await save('screenshot_2.png');

    await go(app(1));
    await save('screenshot_3.png');

    await tester.enterText(find.byType(TextField).at(0), '30');
    await tester.enterText(find.byType(TextField).at(1), '250');
    await tester.pump(const Duration(milliseconds: 300));
    await save('screenshot_4.png');
  });
}
