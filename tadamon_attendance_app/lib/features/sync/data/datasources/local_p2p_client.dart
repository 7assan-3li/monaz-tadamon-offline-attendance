import 'dart:convert';
import 'dart:io';

final class LocalP2pClient {
  LocalP2pClient({HttpClient? client}) : _client = client ?? HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 3);
  }

  final HttpClient _client;

  Future<bool> ping(String host, {int port = 8089}) async {
    try {
      final request = await _client.get(host, port, '/api/v1/health');
      final response = await request.close();
      return response.statusCode == HttpStatus.ok;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, Object?>> fetchPlayers(String host, {int port = 8089}) async {
    final request = await _client.get(host, port, '/api/v1/players');
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('فشل استرجاع اللاعبين عبر الربط اللاسلكي: ${response.statusCode}');
    }
    final body = await utf8.decoder.bind(response).join();
    return jsonDecode(body) as Map<String, Object?>;
  }

  Future<Map<String, Object?>> dispatchSession(
    String host,
    String rawPayload, {
    int port = 8089,
  }) async {
    final request = await _client.post(host, port, '/api/v1/dispatch');
    request.headers.contentType = ContentType.json;
    request.write(rawPayload);
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    return jsonDecode(body) as Map<String, Object?>;
  }

  void close() {
    _client.close(force: true);
  }
}
