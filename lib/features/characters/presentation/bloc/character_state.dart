import '../../domain/domain.dart';

abstract class CharacterState {}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {}

class CharacterLoaded extends CharacterState {
  final List<Character> characters;
  final List<Character> featuredCharacters;
  final bool hasReachedMax;
  final bool isSearching;
  final String searchQuery;
  final CharacterError? inlineError;

  CharacterLoaded({
    required this.characters,
    this.featuredCharacters = const [],
    this.hasReachedMax = false,
    this.isSearching = false,
    this.searchQuery = '',
    this.inlineError,
  });
}

class CharacterError extends CharacterState {
  final String message;
  final ErrorType errorType;
  final bool canRetry;

  CharacterError(
    this.message, {
    this.errorType = ErrorType.generic,
    this.canRetry = true,
  });
}

enum ErrorType { network, server, authentication, notFound, generic }
