import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:marvel/features/characters/presentation/presentation.dart';

import '../../mocks/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SearchCharactersEvent(''));
    registerFallbackValue(GetCharactersEvent());
  });

  testWidgets('should send SearchCharactersEvent with debounce', (
    tester,
  ) async {
    final bloc = MockCharacterBloc();
    when(() => bloc.state).thenReturn(CharacterLoaded(characters: const []));
    when(() => bloc.add(any())).thenReturn(null);
    whenListen(bloc, const Stream<CharacterState>.empty());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<CharacterBloc>.value(
            value: bloc,
            child: const SearchWidget(),
          ),
        ),
      ),
    );

    final field = find.byType(TextField);
    await tester.enterText(field, 'spider');
    await tester.pump(const Duration(milliseconds: 350));

    verify(() => bloc.add(any(that: isA<SearchCharactersEvent>()))).called(1);
  });

  testWidgets('should clear search when clear button is tapped', (
    tester,
  ) async {
    final bloc = MockCharacterBloc();
    when(() => bloc.state).thenReturn(CharacterLoaded(characters: const []));
    when(() => bloc.add(any())).thenReturn(null);
    whenListen(bloc, const Stream<CharacterState>.empty());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<CharacterBloc>.value(
            value: bloc,
            child: const SearchWidget(),
          ),
        ),
      ),
    );

    final field = find.byType(TextField);
    await tester.enterText(field, 'iron');
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    verify(() => bloc.add(any(that: isA<SearchCharactersEvent>()))).called(2);
  });
}
