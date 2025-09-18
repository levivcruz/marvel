import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marvel/features/characters/domain/domain.dart';
import 'package:marvel/features/characters/presentation/presentation.dart';

import '../../mocks/mocks.dart';

void main() {
  Character buildCharacter({
    String description = 'Genius billionaire playboy philanthropist.',
    int items = 3,
  }) {
    final list = List<String>.generate(items, (i) => 'Item $i');
    return Character(
      id: 1,
      name: 'Iron Man',
      description: description,
      imageUrl: 'https://example.com/image.jpg',
      comics: list,
      series: list,
      stories: list,
    );
  }

  testWidgets('should render name and biography', (tester) async {
    final character = buildCharacter();

    await tester.pumpWidget(
      MaterialApp(home: CharacterDetailPage(character: character)),
    );

    expect(find.text('Iron Man'), findsOneWidget);
    expect(find.textContaining('Genius billionaire'), findsOneWidget);
  });

  testWidgets('should render default biography when empty', (tester) async {
    final character = buildCharacter(description: '');

    await tester.pumpWidget(
      MaterialApp(home: CharacterDetailPage(character: character)),
    );

    expect(
      find.text('No biography available for this character.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'should render sections when lists are not empty and "+ N more" when > 5',
    (tester) async {
      final character = buildCharacter(items: 7);

      await tester.pumpWidget(
        MaterialApp(home: CharacterDetailPage(character: character)),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump();

      expect(find.text('COMICS'), findsOneWidget);

      expect(find.text('+ 2 more'), findsWidgets);
    },
  );

  testWidgets('should pop back when back button is tapped', (tester) async {
    final observer = MockNavigatorObserver();
    final character = buildCharacter();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CharacterDetailPage(character: character),
              ),
            ),
            child: const Text('go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tapAt(const Offset(24, 60));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('go'), findsOneWidget);
  });
}
