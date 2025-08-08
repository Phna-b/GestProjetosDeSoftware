// login_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'calendar_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool isRegistering = false;
  bool loading = false;

  void showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> submit() async {
    final username = _userController.text.trim();
    final password = _passController.text;

    if (username.isEmpty || password.isEmpty) {
      showMsg('Preencha usuário e senha.');
      return;
    }

    setState(() => loading = true);

    try {
      if (isRegistering) {
        // 1) tenta registrar
        final resReg = await ApiService.register(username, password);
        final stReg = resReg['status'] as int;
        final bodyReg = resReg['body'] as Map<String, dynamic>;
        if (stReg == 201) {
          // registro OK -> fazer login automático
          showMsg('Cadastro realizado. Entrando...');
          final resLogin = await ApiService.login(username, password);
          final stLogin = resLogin['status'] as int;
          final bodyLogin = resLogin['body'] as Map<String, dynamic>;
          if (stLogin == 200) {
            // token já salvo por ApiService.login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CalendarPage()),
            );
          } else {
            final err = bodyLogin['error'] ?? 'Erro no login automático';
            showMsg(err);
          }
        } else {
          final err = bodyReg['error'] ?? 'Erro no registro (${stReg})';
          showMsg(err);
        }
      } else {
        // login normal
        final resLogin = await ApiService.login(username, password);
        final stLogin = resLogin['status'] as int;
        final bodyLogin = resLogin['body'] as Map<String, dynamic>;
        if (stLogin == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CalendarPage()),
          );
        } else {
          final err = bodyLogin['error'] ?? 'Erro no login (${stLogin})';
          showMsg(err);
        }
      }
    } catch (e) {
      showMsg('Erro de conexão: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isRegistering ? 'Registrar' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Usuário'),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isRegistering ? 'Registrar' : 'Entrar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isRegistering = !isRegistering;
                });
              },
              child: Text(isRegistering ? 'Já tem conta? Fazer login' : 'Não tem conta? Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
