import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../../../core/core.dart';
import '../../../../services/services.dart';
import '../../data/data.dart';

abstract class CharacterRemoteDataSource {
  Future<List<CharacterModel>> getFeaturedCharacters();
  Future<List<CharacterModel>> getCharacters({int offset = 0, int limit = 20});
  Future<List<CharacterModel>> searchCharactersByNameStartsWith(
    String query, {
    int limit = 5,
  });
}

class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  final Dio dio;
  final AnalyticsServiceInterface analyticsService;

  CharacterRemoteDataSourceImpl({
    required this.dio,
    required this.analyticsService,
  });

  @override
  Future<List<CharacterModel>> getCharacters({
    int offset = 0,
    int limit = 20,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(timestamp);

    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.charactersEndpoint}',
        queryParameters: {
          'ts': timestamp,
          'apikey': ApiConstants.publicKey,
          'hash': hash,
          'orderBy': 'name',
          'offset': offset,
          'limit': limit,
        },
      );

      final results = _validateAndExtractResults(response, 'getCharacters');

      return results
          .map((json) => CharacterModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Network error');
    }
  }

  @override
  Future<List<CharacterModel>> searchCharactersByNameStartsWith(
    String query, {
    int limit = 5,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(timestamp);

    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.charactersEndpoint}',
        queryParameters: {
          'ts': timestamp,
          'apikey': ApiConstants.publicKey,
          'hash': hash,
          'nameStartsWith': query,
          'limit': limit,
        },
      );

      final results = _validateAndExtractResults(response, 'searchCharacters');

      return results
          .map((json) => CharacterModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Network error');
    }
  }

  @override
  Future<List<CharacterModel>> getFeaturedCharacters() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(timestamp);

    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.charactersEndpoint}',
        queryParameters: {
          'ts': timestamp,
          'apikey': ApiConstants.publicKey,
          'hash': hash,
          'orderBy': '-modified',
          'limit': 6,
        },
      );

      final results = _validateAndExtractResults(
        response,
        'getFeaturedCharacters',
      );

      return results
          .map((json) => CharacterModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Network error');
    }
  }

  String _generateHash(String timestamp) {
    final input = timestamp + ApiConstants.privateKey + ApiConstants.publicKey;
    final bytes = utf8.encode(input);
    return md5.convert(bytes).toString();
  }

  List<dynamic> _validateAndExtractResults(
    Response response,
    String operation,
  ) {
    final status = response.statusCode;

    if (response.data is! Map<String, dynamic>) {
      throw ServerException('Invalid response format', statusCode: status);
    }

    final responseData = response.data as Map<String, dynamic>;
    final apiCode = responseData['code'] as int?;
    final apiStatus = responseData['status'] as String?;

    if (apiCode != 200 || apiStatus != 'Ok') {
      ('[$operation] API Error - code: $apiCode, status: $apiStatus');

      analyticsService.trackApiError(
        endpoint: operation,
        statusCode: apiCode ?? status ?? 0,
        errorMessage: apiStatus ?? 'Unknown API error',
      );

      throw ServerException(
        'API Error: $apiStatus',
        statusCode: apiCode ?? status,
        apiStatus: apiStatus,
      );
    }

    if (!responseData.containsKey('data') || responseData['data'] is! Map) {
      throw ServerException('Missing data container', statusCode: status);
    }

    final dataContainer = responseData['data'] as Map<String, dynamic>;
    final results = dataContainer['results'];

    if (results is! List) {
      throw ServerException('Invalid results format', statusCode: status);
    }

    return results;
  }
}
