// lib/services/api_service.dart

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'web_http_client.dart';

class ApiService {
  static const String _baseUrl =
      kIsWeb ? "http://127.0.0.1:5000" : "http://10.0.2.2:5000";

  static final http.Client _client = kIsWeb ? WebHttpClient() : http.Client();

  // Cabeçalho padrão que será usado em todas as requisições
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    debugPrint(
        ">>> Enviando POST para $_baseUrl$endpoint com dados: ${jsonEncode(data)}");
    final response = await _client.post(
      Uri.parse('$_baseUrl$endpoint'),
      // LINHA CRUCIAL ADICIONADA: Informa ao servidor que estamos enviando JSON
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );
    debugPrint("<<< Resposta: ${response.statusCode} ${response.body}");
    if (response.statusCode >= 400) {
      // Tenta decodificar o erro do servidor para uma mensagem mais clara
      try {
        final error = jsonDecode(response.body);
        throw Exception(
            error['error'] ?? 'Erro no servidor: ${response.statusCode}');
      } catch (_) {
        throw Exception('Erro no servidor: ${response.statusCode}');
      }
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<dynamic> get(String endpoint) async {
    debugPrint(">>> Enviando GET para $_baseUrl$endpoint");
    final response = await _client.get(
      Uri.parse('$_baseUrl$endpoint'),
      // Também adicionamos aqui para consistência
      headers: _jsonHeaders,
    );
    debugPrint("<<< Resposta: ${response.statusCode} ${response.body}");
    if (response.statusCode >= 400) {
      throw Exception('Erro no servidor: ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<void> logout() async {
    try {
      await post('/logout', {});
    } catch (e) {
      debugPrint("Erro ao fazer logout no servidor: $e");
    } finally {
      debugPrint("--- Sessão do cliente encerrada.");
    }
  }
}
