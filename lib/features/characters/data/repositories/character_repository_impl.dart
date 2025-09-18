import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterRemoteDataSource remoteDataSource;

  CharacterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Character>>> getFeaturedCharacters() async {
    try {
      final characters = await remoteDataSource.getFeaturedCharacters();
      return Right(characters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Character>>> getCharacters({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final characters = await remoteDataSource.getCharacters(
        offset: offset,
        limit: limit,
      );
      return Right(characters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Character>>> searchCharactersByNameStartsWith(
    String query, {
    int limit = 5,
  }) async {
    try {
      final characters = await remoteDataSource
          .searchCharactersByNameStartsWith(query, limit: limit);
      return Right(characters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
