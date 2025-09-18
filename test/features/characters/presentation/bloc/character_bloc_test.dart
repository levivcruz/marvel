import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:marvel/core/core.dart';
import 'package:marvel/features/characters/domain/domain.dart';
import 'package:marvel/features/characters/presentation/presentation.dart';

import '../../mocks/mocks.dart';

void main() {
  late MockGetCharacters mockGetCharacters;
  late MockGetFeatured mockGetFeatured;
  late MockSearchByName mockSearch;
  late CharacterBloc bloc;

  final characters = [
    const Character(
      id: 1,
      name: 'Iron Man',
      description: '',
      imageUrl: 'url',
      comics: [],
      series: [],
      stories: [],
    ),
  ];

  setUp(() {
    mockGetCharacters = MockGetCharacters();
    mockGetFeatured = MockGetFeatured();
    mockSearch = MockSearchByName();
    bloc = CharacterBloc(
      getCharacters: mockGetCharacters,
      getFeaturedCharacters: mockGetFeatured,
      searchByNameStartsWith: mockSearch,
    );
  });

  tearDown(() => bloc.close());

  group('GetCharactersEvent', () {
    blocTest<CharacterBloc, CharacterState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(characters));
        when(
          () => mockGetFeatured(),
        ).thenAnswer((_) async => const Right(<Character>[]));
        return bloc;
      },
      act: (b) => b.add(GetCharactersEvent()),
      expect: () => [isA<CharacterLoading>(), isA<CharacterLoaded>()],
    );

    blocTest<CharacterBloc, CharacterState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Left(ServerFailure('err')));
        return bloc;
      },
      act: (b) => b.add(GetCharactersEvent()),
      expect: () => [isA<CharacterLoading>(), isA<CharacterError>()],
    );
  });

  group('SearchCharactersEvent', () {
    blocTest<CharacterBloc, CharacterState>(
      'empty query: restores original list',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(characters));
        when(
          () => mockGetFeatured(),
        ).thenAnswer((_) async => const Right(<Character>[]));
        return bloc;
      },
      act: (b) async {
        b.add(GetCharactersEvent());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        b.add(SearchCharactersEvent(''));
      },
      skip: 1,
      expect: () => [isA<CharacterLoaded>(), isA<CharacterLoaded>()],
    );

    blocTest<CharacterBloc, CharacterState>(
      'with query: emits Loaded with results',
      build: () {
        when(
          () => mockSearch(any(), limit: any(named: 'limit')),
        ).thenAnswer((_) async => Right(characters));
        return bloc;
      },
      act: (b) => b.add(SearchCharactersEvent('iron')),
      expect: () => [isA<CharacterLoaded>()],
    );
  });

  group('ScrollEvent', () {
    blocTest<CharacterBloc, CharacterState>(
      'triggers LoadMore when 80% reached',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(characters));
        return bloc;
      },
      act: (b) {
        b.emit(CharacterLoaded(characters: characters));
        b.add(ScrollEvent(80, 100));
      },
      verify: (_) {
        verify(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));
      },
    );
  });

  group('MapFailure / GetCharacters errors', () {
    blocTest<CharacterBloc, CharacterState>(
      'NetworkFailure maps to CharacterError.network',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Left(const NetworkFailure('net')));
        return bloc;
      },
      act: (b) => b.add(GetCharactersEvent()),
      expect: () => [
        isA<CharacterLoading>(),
        predicate<CharacterState>(
          (s) => s is CharacterError && s.errorType == ErrorType.network,
        ),
      ],
    );

    blocTest<CharacterBloc, CharacterState>(
      'should emit CharacterError(generic) when Exception is thrown',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('boom'));
        return bloc;
      },
      act: (b) => b.add(GetCharactersEvent()),
      expect: () => [
        isA<CharacterLoading>(),
        predicate<CharacterState>((s) => s is CharacterError),
      ],
    );
  });

  group('GetFeaturedCharactersEvent', () {
    blocTest<CharacterBloc, CharacterState>(
      'success: emits another Loaded when characters already exist',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(characters));
        when(
          () => mockGetFeatured(),
        ).thenAnswer((_) async => Right(characters));
        return bloc;
      },
      act: (b) async {
        b.add(GetCharactersEvent());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        b.add(GetFeaturedCharactersEvent());
      },
      expect: () => [
        isA<CharacterLoading>(),
        isA<CharacterLoaded>(),
        isA<CharacterLoaded>(),
      ],
    );

    blocTest<CharacterBloc, CharacterState>(
      'failure: still emits Loaded when characters already exist',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(characters));
        when(
          () => mockGetFeatured(),
        ).thenAnswer((_) async => Left(const ServerFailure('err')));
        return bloc;
      },
      act: (b) async {
        b.add(GetCharactersEvent());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        b.add(GetFeaturedCharactersEvent());
      },
      expect: () => [
        isA<CharacterLoading>(),
        isA<CharacterLoaded>(),
        isA<CharacterLoaded>(),
      ],
    );
  });

  group('LoadMoreCharactersEvent', () {
    blocTest<CharacterBloc, CharacterState>(
      'empty response: hasReachedMax true',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((invocation) async => Right(characters));
        return bloc;
      },
      act: (b) async {
        b.add(GetCharactersEvent());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => const Right(<Character>[]));
        b.add(LoadMoreCharactersEvent());
      },
      expect: () => [
        isA<CharacterLoading>(),
        isA<CharacterLoaded>(),
        predicate<CharacterState>(
          (s) => s is CharacterLoaded && s.hasReachedMax,
        ),
      ],
    );

    blocTest<CharacterBloc, CharacterState>(
      'load more failure (Left): emits CharacterError (full screen)',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(characters));
        return bloc;
      },
      act: (b) async {
        b.add(GetCharactersEvent());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Left(const ServerFailure('err')));
        b.add(LoadMoreCharactersEvent());
      },
      expect: () => [
        isA<CharacterLoading>(),
        isA<CharacterLoaded>(),
        isA<CharacterError>(),
      ],
    );

    blocTest<CharacterBloc, CharacterState>(
      'load more exception: inline error on Loaded',
      build: () {
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(characters));
        return bloc;
      },
      act: (b) async {
        b.add(GetCharactersEvent());
        await Future<void>.delayed(const Duration(milliseconds: 1));
        when(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('boom'));
        b.add(LoadMoreCharactersEvent());
      },
      expect: () => [
        isA<CharacterLoading>(),
        isA<CharacterLoaded>(),
        predicate<CharacterState>(
          (s) => s is CharacterLoaded && s.inlineError != null,
        ),
      ],
    );
  });

  group('Search failure', () {
    blocTest<CharacterBloc, CharacterState>(
      'search failure emits CharacterError',
      build: () {
        when(
          () => mockSearch(any(), limit: any(named: 'limit')),
        ).thenAnswer((_) async => Left(const NetworkFailure('net')));
        return bloc;
      },
      act: (b) => b.add(SearchCharactersEvent('thor')),
      expect: () => [isA<CharacterError>()],
    );
  });

  group('Scroll no-op when hasReachedMax', () {
    blocTest<CharacterBloc, CharacterState>(
      'does not call getCharacters when hasReachedMax=true',
      build: () => bloc,
      act: (b) {
        b.emit(CharacterLoaded(characters: characters, hasReachedMax: true));
        b.add(ScrollEvent(100, 100));
      },
      verify: (_) {
        verifyNever(
          () => mockGetCharacters(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );
  });
}
