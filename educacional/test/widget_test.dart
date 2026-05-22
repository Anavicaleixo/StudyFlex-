import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educacional/main.dart'; // Mude de educacional para streaming_academico

void main() {
  testWidgets('App carrega corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const StreamingAcademicoApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
