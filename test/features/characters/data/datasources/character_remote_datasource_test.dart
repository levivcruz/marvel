import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:marvel/core/constants/api_constants.dart';
import 'package:marvel/core/error/exceptions.dart';
import 'package:marvel/features/characters/data/datasources/character_remote_datasource.dart';
import 'package:marvel/features/characters/data/models/character_model.dart';

import '../../mocks/mocks.dart';

void main() {
  group('CharacterRemoteDataSourceImpl', () {
    late CharacterRemoteDataSourceImpl dataSource;
    late MockDio mockDio;
    late MockAnalytics mockAnalytics;

    setUpAll(() async {
      dotenv.testLoad(
        fileInput: '''
          MARVEL_PUBLIC_KEY=test_public_key_12345
          MARVEL_PRIVATE_KEY=test_private_key_67890
        ''',
      );
    });

    setUp(() {
      mockDio = MockDio();
      mockAnalytics = MockAnalytics();
      dataSource = CharacterRemoteDataSourceImpl(
        dio: mockDio,
        analyticsService: mockAnalytics,
      );

      when(
        () => mockAnalytics.trackApiError(
          endpoint: any(named: 'endpoint'),
          statusCode: any(named: 'statusCode'),
          errorMessage: any(named: 'errorMessage'),
        ),
      ).thenAnswer((_) async {});
    });

    tearDown(() {
      reset(mockDio);
    });

    group('getCharacters', () {
      test('returns CharacterModel list when call is successful', () async {
        const tOffset = 0;
        const tLimit = 20;
        final tResponse = MockResponse();
        final tResponseData = {
          'code': 200,
          'status': 'Ok',
          'data': {
            'offset': 0,
            'limit': 20,
            'total': 1562,
            'count': 20,
            'results': [
              {
                'id': 1011334,
                'name': '3-D Man',
                'description': '',
                'thumbnail': {
                  'path':
                      'http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784',
                  'extension': 'jpg',
                },
              },
            ],
          },
        };

        when(() => tResponse.statusCode).thenReturn(200);
        when(() => tResponse.data).thenReturn(tResponseData);
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => tResponse);

        final result = await dataSource.getCharacters(
          offset: tOffset,
          limit: tLimit,
        );

        expect(result, isA<List<CharacterModel>>());
        expect(result.length, 1);
        expect(result.first.name, '3-D Man');

        final captured = verify(
          () => mockDio.get(
            '${ApiConstants.baseUrl}${ApiConstants.charactersEndpoint}',
            queryParameters: captureAny(named: 'queryParameters'),
          ),
        ).captured;
        final qp = captured.first as Map<String, dynamic>;
        expect(qp['orderBy'], 'name');
        expect(qp['offset'], tOffset);
        expect(qp['limit'], tLimit);
      });

      test('throws ServerException when API returns error code', () async {
        final tResponse = MockResponse();
        final tErrorResponseData = {
          'code': 401,
          'status': 'InvalidCredentials',
          'message': 'Invalid API key',
        };

        when(() => tResponse.statusCode).thenReturn(200);
        when(() => tResponse.data).thenReturn(tErrorResponseData);
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => tResponse);

        await expectLater(
          () => dataSource.getCharacters(),
          throwsA(
            isA<ServerException>()
                .having((e) => e.statusCode, 'statusCode', 401)
                .having((e) => e.apiStatus, 'apiStatus', 'InvalidCredentials'),
          ),
        );

        verify(
          () => mockAnalytics.trackApiError(
            endpoint: 'getCharacters',
            statusCode: 401,
            errorMessage: 'InvalidCredentials',
          ),
        ).called(1);
      });

      test('throws NetworkException when DioException occurs', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        await expectLater(
          () => dataSource.getCharacters(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('searchCharactersByNameStartsWith', () {
      test('returns list and validates nameStartsWith', () async {
        const tQuery = 'Iron';
        final res = MockResponse();
        when(() => res.statusCode).thenReturn(200);
        when(() => res.data).thenReturn({
          'code': 200,
          'status': 'Ok',
          'data': {'results': []},
        });
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => res);

        await dataSource.searchCharactersByNameStartsWith(tQuery, limit: 5);

        final qp =
            verify(
                  () => mockDio.get(
                    any(),
                    queryParameters: captureAny(named: 'queryParameters'),
                  ),
                ).captured.first
                as Map<String, dynamic>;
        expect(qp['nameStartsWith'], tQuery);
      });

      test('throws NetworkException on DioException', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        await expectLater(
          () => dataSource.searchCharactersByNameStartsWith('iron'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getFeaturedCharacters', () {
      test(
        'returns featured characters (ordered by -modified, limit 6)',
        () async {
          final tResponse = MockResponse();
          final tResponseData = {
            'code': 200,
            'status': 'Ok',
            'data': {
              'results': [
                {
                  'id': 1,
                  'name': 'Featured 1',
                  'description': '',
                  'thumbnail': {
                    'path': 'http://example.com/img',
                    'extension': 'jpg',
                  },
                },
              ],
            },
          };

          when(() => tResponse.statusCode).thenReturn(200);
          when(() => tResponse.data).thenReturn(tResponseData);
          when(
            () => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            ),
          ).thenAnswer((_) async => tResponse);

          final result = await dataSource.getFeaturedCharacters();

          expect(result, isA<List<CharacterModel>>());
          expect(result.first.name, 'Featured 1');

          final captured = verify(
            () => mockDio.get(
              '${ApiConstants.baseUrl}${ApiConstants.charactersEndpoint}',
              queryParameters: captureAny(named: 'queryParameters'),
            ),
          ).captured;
          final qp = captured.first as Map<String, dynamic>;
          expect(qp['orderBy'], '-modified');
          expect(qp['limit'], 6);
        },
      );

      test(
        'throws ServerException and tracks api error on featured failure',
        () async {
          final tResponse = MockResponse();
          final errorData = {'code': 500, 'status': 'ServerError'};
          when(() => tResponse.statusCode).thenReturn(500);
          when(() => tResponse.data).thenReturn(errorData);
          when(
            () => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            ),
          ).thenAnswer((_) async => tResponse);

          await expectLater(
            () => dataSource.getFeaturedCharacters(),
            throwsA(isA<ServerException>()),
          );

          verify(
            () => mockAnalytics.trackApiError(
              endpoint: 'getFeaturedCharacters',
              statusCode: 500,
              errorMessage: 'ServerError',
            ),
          ).called(1);
        },
      );

      test('throws NetworkException when DioException occurs', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        await expectLater(
          () => dataSource.getFeaturedCharacters(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('_validateAndExtractResults validations', () {
      test('throws when response.data is not a Map', () async {
        final tResponse = MockResponse();
        when(() => tResponse.statusCode).thenReturn(200);
        when(() => tResponse.data).thenReturn('invalid');
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => tResponse);

        await expectLater(
          () => dataSource.getCharacters(),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws when data container is missing or not a Map', () async {
        final tResponse = MockResponse();
        when(() => tResponse.statusCode).thenReturn(200);
        when(() => tResponse.data).thenReturn({'code': 200, 'status': 'Ok'});
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => tResponse);

        await expectLater(
          () => dataSource.getCharacters(),
          throwsA(isA<ServerException>()),
        );
      });

      test('throws when results is not a List', () async {
        final tResponse = MockResponse();
        when(() => tResponse.statusCode).thenReturn(200);
        when(() => tResponse.data).thenReturn({
          'code': 200,
          'status': 'Ok',
          'data': {'results': 'oops'},
        });
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => tResponse);

        await expectLater(
          () => dataSource.getCharacters(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('search network error', () {
      test('throws NetworkException on DioException in search', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        await expectLater(
          () => dataSource.searchCharactersByNameStartsWith('iron'),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
}
