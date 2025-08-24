import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/calendar_page.dart';
import '../pages/favorites_page.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final tabs = [
      const CalendarPage(),
      const FavoritesPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('4ª SECOMP - DECSI'),
        actions: [
          CircleAvatar(
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Sair',
            onPressed: () => context.read<AuthService>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Calendário'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Favoritos'),
        ],
      ),
    );
  }
}