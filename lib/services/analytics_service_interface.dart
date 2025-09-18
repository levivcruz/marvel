/// Interface for analytics services
abstract class AnalyticsServiceInterface {
  /// Initializes the analytics service
  Future<void> initialize();

  /// Tracks a custom event
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  });

  /// Tracks screen view
  Future<void> trackScreen(String screenName);

  /// Tracks character view
  Future<void> trackCharacterView(int characterId, String characterName);

  /// Tracks character search
  Future<void> trackCharacterSearch(String query, int resultsCount);

  /// Tracks API error
  Future<void> trackApiError({
    required String endpoint,
    required int statusCode,
    required String errorMessage,
  });
}
