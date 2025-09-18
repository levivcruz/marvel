import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'analytics_service_interface.dart';

/// Implementation of the analytics service using the native MethodChannel
class AnalyticsServiceImpl implements AnalyticsServiceInterface {
  static const MethodChannel _channel = MethodChannel('com.marvel.analytics');

  @override
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      debugPrint('Analytics: Error initializing - ${e.message}');
    }
  }

  @override
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _channel.invokeMethod('trackEvent', {
        'eventName': eventName,
        'parameters': parameters ?? {},
      });
    } on PlatformException catch (e) {
      debugPrint('Analytics: Error tracking $eventName - ${e.message}');
    }
  }

  @override
  Future<void> trackScreen(String screenName) async {
    try {
      await _channel.invokeMethod('trackScreen', {'screenName': screenName});
    } on PlatformException catch (e) {
      debugPrint('Analytics: Error tracking screen $screenName - ${e.message}');
    }
  }

  @override
  Future<void> trackCharacterView(int characterId, String characterName) async {
    await trackEvent(
      eventName: 'character_view',
      parameters: {
        'character_id': characterId,
        'character_name': characterName,
      },
    );
  }

  @override
  Future<void> trackCharacterSearch(String query, int resultsCount) async {
    await trackEvent(
      eventName: 'character_search',
      parameters: {'search_query': query, 'results_count': resultsCount},
    );
  }

  @override
  Future<void> trackApiError({
    required String endpoint,
    required int statusCode,
    required String errorMessage,
  }) async {
    await trackEvent(
      eventName: 'api_error',
      parameters: {
        'endpoint': endpoint,
        'status_code': statusCode,
        'error_message': errorMessage,
      },
    );
  }
}
