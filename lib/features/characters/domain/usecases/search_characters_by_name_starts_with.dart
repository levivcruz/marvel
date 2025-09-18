import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../domain.dart';

class SearchCharactersByNameStartsWith {
  final CharacterRepository repository;

  SearchCharactersByNameStartsWith(this.repository);

  Future<Either<Failure, List<Character>>> call(
    String query, {
    int limit = 20,
  }) {
    return repository.searchCharactersByNameStartsWith(query, limit: limit);
  }
}
