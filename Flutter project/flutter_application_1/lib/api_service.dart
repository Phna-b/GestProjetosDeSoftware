// lib/services/api_service.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../web_http_client.dart'; // se você usa WebHttpClient no web

class ApiService {
  // ajuste a base se necessário; em emulador Android use 10.0.2.2
  static String _baseUrl =
      kIsWeb ? "http://127.0.0.1:5000" : "http://10.0.2.2:5000";

  static final http.Client _client = kIsWeb ? WebHttpClient() : http.Client();

  // Token JWT em memória (persistir depois com secure storage se desejar)
  static String? _authToken;

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static void setBaseUrl(String url) {
    _baseUrl = url;
    debugPrint('ApiService: baseUrl alterado para $_baseUrl');
  }

  static void setAuthToken(String? token) {
    _authToken = token;
    debugPrint('ApiService: token salvo (length=${token?.length ?? 0})');
  }

  static Map<String, String> _headersWithAuth() {
    final headers = Map<String, String>.from(_jsonHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Generic POST using client
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {Duration timeout = const Duration(seconds: 10)}) async {
    debugPrint(">>> POST $_baseUrl$endpoint -> ${jsonEncode(data)}");
    final resp = await _client
        .post(Uri.parse('$_baseUrl$endpoint'),
            headers: _headersWithAuth(), body: jsonEncode(data))
        .timeout(timeout);
    debugPrint("<<< ${resp.statusCode} ${resp.body}");
    if (resp.body.isEmpty) return {'status': resp.statusCode, 'body': null};
    final body = jsonDecode(utf8.decode(resp.bodyBytes));
    if (resp.statusCode >= 400) {
      return {'status': resp.statusCode, 'body': body};
    }
    return {'status': resp.statusCode, 'body': body};
  }

  // Generic GET
  static Future<dynamic> get(String endpoint,
      {Duration timeout = const Duration(seconds: 10)}) async {
    debugPrint(">>> GET $_baseUrl$endpoint");
    final resp = await _client
        .get(Uri.parse('$_baseUrl$endpoint'), headers: _headersWithAuth())
        .timeout(timeout);
    debugPrint("<<< ${resp.statusCode} ${resp.body}");
    if (resp.body.isEmpty) {
      if (resp.statusCode >= 400) {
        throw Exception('Erro no servidor: ${resp.statusCode}');
      }
      return {'status': resp.statusCode, 'body': null};
    }
    final body = jsonDecode(utf8.decode(resp.bodyBytes));
    if (resp.statusCode >= 400) {
      throw Exception(body['error'] ?? 'Erro no servidor: ${resp.statusCode}');
    }
    return body;
  }

  static Future<void> logout() async {
    try {
      await post('/logout', {});
    } catch (e) {
      debugPrint("Erro ao fazer logout no servidor: $e");
    } finally {
      setAuthToken(null);
      debugPrint("--- Sessão do cliente encerrada.");
    }
  }

  // --- Helpers específicos
  static Future<Map<String, dynamic>> register(
      String username, String password) async {
    try {
      final resp = await _client.post(Uri.parse('$_baseUrl/register'),
          headers: _jsonHeaders,
          body: jsonEncode({'username': username, 'password': password}));
      final body =
          resp.body.isNotEmpty ? jsonDecode(utf8.decode(resp.bodyBytes)) : {};
      return {'status': resp.statusCode, 'body': body};
    } catch (e) {
      debugPrint('ApiService.register erro: $e');
      return {'status': 0, 'body': {'error': 'Falha de conexão: $e'}};
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final resp = await _client.post(Uri.parse('$_baseUrl/login'),
          headers: _jsonHeaders,
          body: jsonEncode({'username': username, 'password': password}));
      final body =
          resp.body.isNotEmpty ? jsonDecode(utf8.decode(resp.bodyBytes)) : {};
      if (resp.statusCode == 200 && body['token'] != null) {
        setAuthToken(body['token'] as String);
      }
      return {'status': resp.statusCode, 'body': body};
    } catch (e) {
      debugPrint('ApiService.login erro: $e');
      return {'status': 0, 'body': {'error': 'Falha de conexão: $e'}};
    }
  }

  // subscribe / unsubscribe
  static Future<Map<String, dynamic>> subscribeEvent(int eventId) async {
    try {
      final resp = await _client.post(Uri.parse('$_baseUrl/subscribe'),
          headers: _headersWithAuth(),
          body: jsonEncode({'event_id': eventId}));
      final body =
          resp.body.isNotEmpty ? jsonDecode(utf8.decode(resp.bodyBytes)) : {};
      return {'status': resp.statusCode, 'body': body};
    } catch (e) {
      debugPrint('subscribeEvent erro: $e');
      return {'status': 0, 'body': {'error': 'Falha de conexão: $e'}};
    }
  }

  static Future<Map<String, dynamic>> unsubscribeEvent(int eventId) async {
    try {
      final resp = await _client.post(Uri.parse('$_baseUrl/unsubscribe'),
          headers: _headersWithAuth(),
          body: jsonEncode({'event_id': eventId}));
      final body =
          resp.body.isNotEmpty ? jsonDecode(utf8.decode(resp.bodyBytes)) : {};
      return {'status': resp.statusCode, 'body': body};
    } catch (e) {
      debugPrint('unsubscribeEvent erro: $e');
      return {'status': 0, 'body': {'error': 'Falha de conexão: $e'}};
    }
  }

  // create event
  static Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> payload) async {
    try {
      final resp = await _client.post(Uri.parse('$_baseUrl/events'),
          headers: _headersWithAuth(), body: jsonEncode(payload));
      final body =
          resp.body.isNotEmpty ? jsonDecode(utf8.decode(resp.bodyBytes)) : {};
      return {'status': resp.statusCode, 'body': body};
    } catch (e) {
      debugPrint('createEvent erro: $e');
      return {'status': 0, 'body': {'error': 'Falha de conexão: $e'}};
    }
  }

  // get my agenda
  static Future<List<dynamic>> getMyAgenda() async {
    final resp =
        await _client.get(Uri.parse('$_baseUrl/my_agenda'), headers: _headersWithAuth());
    if (resp.statusCode == 200) {
      final body = resp.body.isNotEmpty ? jsonDecode(utf8.decode(resp.bodyBytes)) : [];
      return body as List<dynamic>;
    } else {
      throw Exception('Erro ao carregar agenda: ${resp.statusCode}');
    }
  }
  
    // delete event (only owner can delete)
  static Future<Map<String, dynamic>> deleteEvent(int eventId) async {
    try {
      final resp = await _client.delete(
        Uri.parse('$_baseUrl/events/$eventId'),
        headers: _headersWithAuth(),
      );
      final body = resp.body.isNotEmpty ? jsonDecode(utf8.decode(resp.bodyBytes)) : {};
      return {'status': resp.statusCode, 'body': body};
    } catch (e) {
      debugPrint('deleteEvent erro: $e');
      return {'status': 0, 'body': {'error': 'Falha de conexão: $e'}};
    }
  }

  // fetch events by date: '/calendar/<date>' or '/my/events/<date>'
  static Future<Map<String, dynamic>> fetchEvents(String date,
      {bool onlyMyEvents = false}) async {
    final endpoint = onlyMyEvents ? '/my/events/$date' : '/calendar/$date';
    try {
      final resp = await _client.get(Uri.parse('$_baseUrl$endpoint'),
          headers: _headersWithAuth());
      final body =
          resp.body.isNotEmpty ? jsonDecode(utf8.decode(resp.bodyBytes)) : [];
      return {'status': resp.statusCode, 'body': body};
    } catch (e) {
      debugPrint('ApiService.fetchEvents erro: $e');
      return {'status': 0, 'body': {'error': 'Falha de conexão: $e'}};
    }
  }
}
