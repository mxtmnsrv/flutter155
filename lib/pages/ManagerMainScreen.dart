import 'package:flutter/material.dart';
import 'package:GarageSync/services/auth/auth_service.dart';
import 'package:GarageSync/pages/ChatPagesList.dart';

class ManagerMainScreen extends StatelessWidget {
  final String username;

  const ManagerMainScreen({required this.username, super.key});

  void _logout() {
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GarageSync - $username'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Menü")),
            ListTile(
              title: const Text("Messaging"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatListScreen()),
                );
              },
            ),
            ListTile(
              title: const Text("Update History"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Appointment (Nearby)"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Supportation to AI"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Support Part Search"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Manager Ana Ekranı'),
      ),
    );
  }
}
