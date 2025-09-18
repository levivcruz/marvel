import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:marvel/features/characters/domain/domain.dart';
import 'package:marvel/features/characters/presentation/presentation.dart';
import 'package:marvel/injection/injection.dart' as di;
import 'package:marvel/services/services.dart';

import '../../mocks/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCharacterEvent());
  });

  setUp(() async {
    await di.sl.reset();
    final analytics = MockAnalytics();
    when(() => analytics.initialize()).thenAnswer((_) async {});
    when(() => analytics.trackScreen(any())).thenAnswer((_) async {});
    when(
      () => analytics.trackEvent(
        eventName: any(named: 'eventName'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    di.sl.registerLazySingleton<AnalyticsServiceInterface>(() => analytics);
  });
  testWidgets('should render AppLoading when CharacterLoading', (tester) async {
    final bloc = MockCharacterBloc();
    when(() => bloc.state).thenReturn(CharacterLoading());
    whenListen(bloc, const Stream<CharacterState>.empty());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CharacterBloc>.value(
          value: bloc,
          child: const CharactersPage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('should render content when CharacterLoaded', (tester) async {
    final bloc = MockCharacterBloc();
    when(() => bloc.state).thenReturn(CharacterLoaded(characters: const []));
    whenListen(bloc, const Stream<CharacterState>.empty());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CharacterBloc>.value(
          value: bloc,
          child: const CharactersPage(),
        ),
      ),
    );

    expect(find.text('MARVEL CHARACTERS LIST'), findsOneWidget);
  });

  testWidgets('should send ScrollEvent when scrolling', (tester) async {
    final bloc = MockCharacterBloc();
    final many = List<Character>.generate(
      40,
      (i) => Character(
        id: i,
        name: 'Char $i',
        description: '',
        imageUrl: 'url',
        comics: const [],
        series: const [],
        stories: const [],
      ),
    );
    when(() => bloc.state).thenReturn(CharacterLoaded(characters: many));
    when(() => bloc.add(any())).thenReturn(null);
    whenListen(bloc, const Stream<CharacterState>.empty());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CharacterBloc>.value(
          value: bloc,
          child: const CharactersPage(),
        ),
      ),
    );

    await tester.pump();

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -300),
    );
    await tester.pump();

    verify(
      () => bloc.add(any(that: isA<ScrollEvent>())),
    ).called(greaterThanOrEqualTo(1));
  });
}
