import 'dart:convert';
import 'dart:io';

class CloudSyncApiClient {
  CloudSyncApiClient({
    String? baseUrl,
    HttpClient? client,
  })  : baseUrl = baseUrl ?? 'https://attendance.monaz.dev',
        _client = client ?? HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 8);
  }

  final String baseUrl;
  final HttpClient _client;

  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/api/sync/sessions');
      final request = await _client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 5));
      return response.statusCode == HttpStatus.ok;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> registerDevice(Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('$baseUrl/api/sync/device/register');
      final request = await _client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
      final response = await request.close().timeout(const Duration(seconds: 10));
      if (response.statusCode != HttpStatus.ok && response.statusCode != HttpStatus.created) {
        return null;
      }
      final body = await utf8.decoder.bind(response).join();
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> pushMasterData(Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('$baseUrl/api/sync/master-data/push');
      final request = await _client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
      final response = await request.close().timeout(const Duration(seconds: 15));
      if (response.statusCode != HttpStatus.created && response.statusCode != HttpStatus.ok) {
        return null;
      }
      final body = await utf8.decoder.bind(response).join();
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> pullMasterData({String? clubId}) async {
    try {
      final query = clubId != null ? '?club_id=$clubId' : '';
      final uri = Uri.parse('$baseUrl/api/sync/master-data/pull$query');
      final request = await _client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 12));
      if (response.statusCode != HttpStatus.ok) {
        return null;
      }
      final body = await utf8.decoder.bind(response).join();
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> dispatchSession(Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('$baseUrl/api/sync/dispatch');
      final request = await _client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
      final response = await request.close().timeout(const Duration(seconds: 10));
      return response.statusCode == HttpStatus.created || response.statusCode == HttpStatus.ok;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDispatchedSessions({String? teamId, String? clubId}) async {
    try {
      final queryParams = <String>[];
      if (teamId != null && teamId.isNotEmpty) queryParams.add('team_id=$teamId');
      if (clubId != null && clubId.isNotEmpty) queryParams.add('club_id=$clubId');
      final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final uri = Uri.parse('$baseUrl/api/sync/sessions$query');
      final request = await _client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 10));
      if (response.statusCode != HttpStatus.ok) {
        return [];
      }
      final body = await utf8.decoder.bind(response).join();
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final list = decoded['sessions'] as List<dynamic>? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> approveSession(String sessionUuid, {String? approverDeviceId}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/sync/sessions/$sessionUuid/approve');
      final request = await _client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({
        'approver_device_id': approverDeviceId ?? 'master_admin',
      }));
      final response = await request.close().timeout(const Duration(seconds: 8));
      return response.statusCode == HttpStatus.ok;
    } catch (_) {
      return false;
    }
  }

  void close() {
    _client.close(force: true);
  }
}
