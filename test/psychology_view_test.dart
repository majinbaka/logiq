import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trading_diary/app/app.dart';
import 'package:trading_diary/core/storage/storage_initializer.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('psychology_view_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  testWidgets('adds discipline review and filters by scope', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Psychology').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Review'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trade').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journal').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Stayed patient today');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();

    expect(find.text('Stayed patient today'), findsOneWidget);

    await tester.tap(find.text('Trade').first);
    await tester.pumpAndSettle();
    expect(find.text('Stayed patient today'), findsNothing);

    await tester.tap(find.text('Journal').first);
    await tester.pumpAndSettle();
    expect(find.text('Stayed patient today'), findsOneWidget);
  });
}
