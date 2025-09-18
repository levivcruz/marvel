class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? apiStatus;

  const ServerException(this.message, {this.statusCode, this.apiStatus});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);
}
