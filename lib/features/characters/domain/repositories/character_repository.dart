import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../entities/entities.dart';

abstract class CharacterRepository {
  Future<Either<Failure, List<Character>>> getFeaturedCharacters();
  Future<Either<Failure, List<Character>>> getCharacters({
    int offset = 0,
    int limit = 20,
  });
  Future<Either<Failure, List<Character>>> searchCharactersByNameStartsWith(
    String query, {
    int limit = 5,
  });
}
