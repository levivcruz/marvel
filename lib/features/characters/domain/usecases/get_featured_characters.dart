import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../domain.dart';

class GetFeaturedCharacters {
  final CharacterRepository repository;

  GetFeaturedCharacters(this.repository);

  Future<Either<Failure, List<Character>>> call() async {
    return repository.getFeaturedCharacters();
  }
}
