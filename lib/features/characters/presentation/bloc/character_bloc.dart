import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../domain/domain.dart';
import '../presentation.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final GetCharacters getCharacters;
  final GetFeaturedCharacters getFeaturedCharacters;
  final SearchCharactersByNameStartsWith searchByNameStartsWith;

  static const int _limit = 20;
  List<Character> _characters = [];
  List<Character> _featuredCharacters = [];
  int _currentOffset = 0;
  bool _isLoadingMore = false;

  CharacterBloc({
    required this.getCharacters,
    required this.getFeaturedCharacters,
    required this.searchByNameStartsWith,
  }) : super(CharacterInitial()) {
    on<GetCharactersEvent>(_onGetCharacters);
    on<GetFeaturedCharactersEvent>(_onGetFeaturedCharacters);
    on<LoadMoreCharactersEvent>(_onLoadMoreCharacters);
    on<SearchCharactersEvent>(_onSearchCharacters);
    on<ScrollEvent>(_onScroll);
  }

  Future<void> _onGetCharacters(
    GetCharactersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    emit(CharacterLoading());

    try {
      _characters = [];
      _currentOffset = 0;
      _isLoadingMore = false;

      final result = await getCharacters(
        offset: event.offset,
        limit: event.limit,
      );
      result.fold((failure) => emit(_mapFailureToError(failure)), (characters) {
        _characters = characters;
        _currentOffset = event.limit;
        emit(
          CharacterLoaded(
            characters: _characters,
            featuredCharacters: _featuredCharacters,
            hasReachedMax: characters.length < event.limit,
          ),
        );
      });
    } on Failure catch (failure) {
      emit(_mapFailureToError(failure));
    } catch (e) {
      emit(
        CharacterError('Unexpected error: $e', errorType: ErrorType.generic),
      );
    }
  }

  Future<void> _onLoadMoreCharacters(
    LoadMoreCharactersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    try {
      final result = await getCharacters(offset: _currentOffset, limit: _limit);
      result.fold((failure) => emit(_mapFailureToError(failure)), (
        newCharacters,
      ) {
        if (newCharacters.isEmpty) {
          emit(
            CharacterLoaded(
              characters: _characters,
              featuredCharacters: _featuredCharacters,
              hasReachedMax: true,
            ),
          );
          _isLoadingMore = false;
          return;
        }
        _characters.addAll(newCharacters);
        _currentOffset += _limit;
        emit(
          CharacterLoaded(
            characters: _characters,
            featuredCharacters: _featuredCharacters,
            hasReachedMax: newCharacters.length < _limit,
          ),
        );
      });
    } on Failure catch (failure) {
      emit(
        CharacterLoaded(
          characters: _characters,
          featuredCharacters: _featuredCharacters,
          hasReachedMax: false,
          inlineError: _mapFailureToError(failure),
        ),
      );
    } catch (e) {
      emit(
        CharacterLoaded(
          characters: _characters,
          featuredCharacters: _featuredCharacters,
          hasReachedMax: false,
          inlineError: CharacterError(
            'Unexpected error: $e',
            errorType: ErrorType.generic,
          ),
        ),
      );
    }
    _isLoadingMore = false;
  }

  Future<void> _onGetFeaturedCharacters(
    GetFeaturedCharactersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    final result = await getFeaturedCharacters();
    result.fold(
      (failure) {
        _featuredCharacters = [];
        if (_characters.isNotEmpty) {
          emit(
            CharacterLoaded(
              characters: _characters,
              featuredCharacters: _featuredCharacters,
              hasReachedMax: _characters.length < _limit,
            ),
          );
        }
      },
      (featured) {
        _featuredCharacters = featured;
        if (_characters.isNotEmpty) {
          emit(
            CharacterLoaded(
              characters: _characters,
              featuredCharacters: _featuredCharacters,
              hasReachedMax: _characters.length < _limit,
            ),
          );
        }
      },
    );
  }

  CharacterError _mapFailureToError(Failure failure) {
    if (failure is NetworkFailure) {
      return CharacterError(
        'Check your internet connection',
        errorType: ErrorType.network,
        canRetry: true,
      );
    }

    return CharacterError(
      'Something went wrong. Please try again.',
      errorType: ErrorType.server,
      canRetry: true,
    );
  }

  Future<void> _onSearchCharacters(
    SearchCharactersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(
        CharacterLoaded(
          characters: _characters,
          featuredCharacters: _featuredCharacters,
          hasReachedMax: _characters.length < _limit,
          searchQuery: '',
        ),
      );
      return;
    }

    final result = await searchByNameStartsWith(query, limit: event.limit);
    result.fold(
      (failure) => emit(_mapFailureToError(failure)),
      (searchResults) => emit(
        CharacterLoaded(
          characters: searchResults,
          featuredCharacters: _featuredCharacters,
          hasReachedMax: true,
          searchQuery: query,
        ),
      ),
    );
  }

  void _onScroll(ScrollEvent event, Emitter<CharacterState> emit) {
    if (event.scrollPosition >= event.maxScrollExtent * 0.8) {
      final currentState = state;
      if (currentState is CharacterLoaded &&
          !currentState.hasReachedMax &&
          !_isLoadingMore) {
        add(LoadMoreCharactersEvent());
      }
    }
  }
}
