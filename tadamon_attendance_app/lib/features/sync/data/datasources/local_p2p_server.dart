import 'dart:convert';
import 'dart:io';

typedef PlayersJsonProvider = Future<Map<String, Object?>> Function();
typedef DispatchHandler = Future<Map<String, Object?>> Function(String rawPayload);

final class LocalP2pServer {
  LocalP2pServer({
    required this.playersProvider,
    required this.dispatchHandler,
  });

  final PlayersJsonProvider playersProvider;
  final DispatchHandler dispatchHandler;

  HttpServer? _server;

  bool get isRunning => _server != null;
  int? get port => _server?.port;

  Future<int> start({int port = 8089}) async {
    if (_server != null) return _server!.port;

    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _server!.listen(_handleRequest);
    return _server!.port;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (request.method == 'GET' && path == '/api/v1/health') {
        _sendJson(request, {'status': 'ok', 'service': 'tadamon_master'});
        return;
      }

      if (request.method == 'GET' && path == '/api/v1/players') {
        final data = await playersProvider();
        _sendJson(request, data);
        return;
      }

      if (request.method == 'POST' && path == '/api/v1/dispatch') {
        final content = await utf8.decoder.bind(request).join();
        final result = await dispatchHandler(content);
        _sendJson(request, result);
        return;
      }

      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found');
      await request.response.close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Server Error: $e');
      await request.response.close();
    }
  }

  void _sendJson(HttpRequest request, Map<String, Object?> data) {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(data));
    request.response.close();
  }
}
