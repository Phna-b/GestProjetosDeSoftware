// lib/web_http_client.dart

import 'package:http/browser_client.dart';

/// Um cliente HTTP customizado para a web que garante que as credenciais (cookies)
/// sejam enviadas em requisições cross-origin.
class WebHttpClient extends BrowserClient {
  
  /// A linha mágica que resolve o problema de autenticação.
  /// Isso instrui o navegador a incluir cookies de sessão em todas as
  /// requisições feitas por este cliente.
  @override
  bool get withCredentials => true;
}