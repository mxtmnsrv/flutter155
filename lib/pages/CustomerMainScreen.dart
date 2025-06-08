import 'package:flutter/material.dart';
import 'package:GarageSync/services/auth/auth_service.dart';
import 'package:GarageSync/pages/ChatPagesList.dart';
import 'package:GarageSync/pages/add_vehicle_page.dart';
import 'package:GarageSync/pages/select_vehicle_page.dart';
import 'package:GarageSync/pages/select_vehicle_for_history_page.dart';

class CustomerMainScreen extends StatelessWidget {
  final String username;

  const CustomerMainScreen({required this.username, super.key});

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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Menü")),
            ListTile(
              title: const Text("Nearby Workshop"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Messaging"),
              onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatListScreen()),
                  );
                   },
            ),
            ListTile(
              title: const Text("See Repair History"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectVehicleForHistoryPage()),
                );
              },
            ),
            ListTile(
              title: const Text("AI Chatbot"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Part Search"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Vehicles"),
              onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SelectVehiclePage()),
                  );
              },
            ),
            ListTile(
              title: const Text("Add Vehicle"),
              onTap:() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddVehiclePage()),
                  );
              }
            )
          ],
        ),
      ),
      body: const Center(
        child: Text('Customer Ana Ekranı'),
      ),
    );
  }
}