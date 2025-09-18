import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../services/services.dart';
import '../features/characters/data/data.dart';
import '../features/characters/domain/domain.dart';
import '../features/characters/presentation/presentation.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio());

  // Services
  sl.registerLazySingleton<AnalyticsServiceInterface>(
    () => AnalyticsServiceImpl()..initialize(),
  );

  // Data sources
  sl.registerLazySingleton<CharacterRemoteDataSource>(
    () => CharacterRemoteDataSourceImpl(
      dio: sl<Dio>(),
      analyticsService: sl<AnalyticsServiceInterface>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(
      remoteDataSource: sl<CharacterRemoteDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCharacters(sl<CharacterRepository>()));
  sl.registerLazySingleton(
    () => GetFeaturedCharacters(sl<CharacterRepository>()),
  );
  sl.registerLazySingleton(
    () => SearchCharactersByNameStartsWith(sl<CharacterRepository>()),
  );

  // Bloc
  sl.registerFactory(
    () => CharacterBloc(
      getCharacters: sl<GetCharacters>(),
      getFeaturedCharacters: sl<GetFeaturedCharacters>(),
      searchByNameStartsWith: sl<SearchCharactersByNameStartsWith>(),
    ),
  );
}
