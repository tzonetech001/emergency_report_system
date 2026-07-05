class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  Future<Map<String, dynamic>> get(String path) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return <String, dynamic>{'path': path, 'status': 'ok'};
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return <String, dynamic>{'path': path, 'data': data ?? <String, dynamic>{}, 'status': 'ok'};
  }
}
