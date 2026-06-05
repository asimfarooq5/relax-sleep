import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:relax_sleep/main.dart';

void main() {
  testWidgets('makes the sound screens accessible', (tester) async {
    await tester.pumpWidget(const SoundMixApp());

    expect(find.text('All Sounds'), findsOneWidget);
    expect(find.textContaining('Your Mix'), findsOneWidget);

    await tester.tap(find.text('Mix'));
    await tester.pumpAndSettle();
    expect(find.text('Rain Mix'), findsOneWidget);
    expect(find.text('Add New Sound'), findsOneWidget);

    await tester.tap(find.text('Playing'));
    await tester.pumpAndSettle();
    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Cherry Blossom'), findsOneWidget);

    await tester.tap(find.text('Current'));
    await tester.pumpAndSettle();
    expect(find.text('Your Current Mix'), findsOneWidget);
  });

  testWidgets('mix controls update shared playback state', (tester) async {
    await tester.pumpWidget(const SoundMixApp());

    await tester.drag(find.byType(ListView), const Offset(0, -360));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_circle_outline_rounded).first);
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, 360));
    await tester.pump();
    expect(find.textContaining('5 active sounds'), findsOneWidget);

    await tester.tap(find.text('Playing'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.tap(find.text('Current'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('premium offer remains accessible', (tester) async {
    await tester.pumpWidget(const SoundMixApp());

    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Relax & Sleep\nBetter'), findsOneWidget);
    expect(find.text('Get Discount'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('All Sounds'), findsOneWidget);
  });
}
