import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../domain.dart';

class GetCharacters {
  final CharacterRepository repository;

  GetCharacters(this.repository);

  Future<Either<Failure, List<Character>>> call({
    int offset = 0,
    int limit = 20,
  }) {
    return repository.getCharacters(offset: offset, limit: limit);
  }
}
