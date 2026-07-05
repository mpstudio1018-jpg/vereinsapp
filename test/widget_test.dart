// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const VereinsApp());

    expect(find.text('Willkommen zurück!'), findsOneWidget);
    expect(find.text('C-Jugend Dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.person_add), findsOneWidget);
  });

  testWidgets('Terminformular öffnet und speichert neuen Termin',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VereinsApp());
    await tester.pumpAndSettle();

    final addTerminButton = find.byTooltip('Neuen Termin anlegen');
    expect(addTerminButton, findsOneWidget);

    await tester.tap(addTerminButton);
    await tester.pumpAndSettle();

    expect(find.text('Neuen Termin erstellen'), findsOneWidget);

    final eventField = find.bySemanticsLabel('Event-Name *');
    final datumField = find.bySemanticsLabel('Datum (TT.MM) *');
    final zeitField = find.bySemanticsLabel('Uhrzeit (HH:MM) *');
    final ortField = find.bySemanticsLabel('Spielort / Platz *');
    final createButton = find.widgetWithText(ElevatedButton, 'Erstellen');

    expect(eventField, findsOneWidget);
    expect(datumField, findsOneWidget);
    expect(zeitField, findsOneWidget);
    expect(ortField, findsOneWidget);
    expect(createButton, findsOneWidget);

    final ElevatedButton buttonWidget = tester.widget(createButton);
    expect(buttonWidget.onPressed, isNull);

    await tester.enterText(eventField, 'Neuer Testtermin');
    await tester.enterText(datumField, '31.12');
    await tester.enterText(zeitField, '18:45');
    await tester.enterText(ortField, 'Testplatz');
    await tester.pumpAndSettle();

    final ElevatedButton enabledButtonWidget = tester.widget(createButton);
    expect(enabledButtonWidget.onPressed, isNotNull);

    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('Termin erstellt'), findsOneWidget);
    expect(find.text('Neuen Termin erstellen'), findsNothing);
  });

  testWidgets('Terminformular validiert Pflichtfelder',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VereinsApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Neuen Termin anlegen'));
    await tester.pumpAndSettle();

    final createButton = find.widgetWithText(ElevatedButton, 'Erstellen');
    expect(createButton, findsOneWidget);

    final ElevatedButton buttonWidget = tester.widget(createButton);
    expect(buttonWidget.onPressed, isNull);

    await tester.enterText(find.bySemanticsLabel('Event-Name *'), 'Kurz');
    await tester.enterText(find.bySemanticsLabel('Datum (TT.MM) *'), '01.01');
    await tester.enterText(find.bySemanticsLabel('Uhrzeit (HH:MM) *'), '12:00');
    await tester.enterText(find.bySemanticsLabel('Spielort / Platz *'), 'Halle');
    await tester.pumpAndSettle();

    final ElevatedButton enabledButtonWidget = tester.widget(createButton);
    expect(enabledButtonWidget.onPressed, isNotNull);
  });
}
