// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'api_service.dart';
import 'login_page.dart';
import 'calendar_page.dart';
import 'my_agenda_page.dart';

// Gerencia o estado de autenticação do usuário na aplicação.
class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  int? _userId;

  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId;

  Future<bool> login(String username, String password) async {
    try {
      final response = await ApiService.post('/login', {
        'username': username,
        'password': password,
      });

      if (response.containsKey('user_id')) {
        _isAuthenticated = true;
        _userId = response['user_id'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erro no login do AuthProvider: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout(); // Chama o logout da API
    _isAuthenticated = false;
    _userId = null;
    notifyListeners();
  }
}

void main() {
  // Inicializa a formatação de data para o local pt_BR.
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => AuthProvider(),
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Eventos',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // Decide qual página mostrar com base no estado de autenticação.
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // Se o usuário estiver autenticado, vai para a página do calendário.
          // Caso contrário, para a página de login.
          return auth.isAuthenticated
              ? const CalendarPage()
              : const LoginPage();
        },
      ),
      // Define as rotas nomeadas da aplicação.
      routes: {
        '/login': (context) => const LoginPage(),
        '/calendar': (context) => const CalendarPage(),
        '/my_agenda': (context) => const MyAgendaPage(),
      },
    );
  }
}
