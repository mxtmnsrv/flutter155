import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'repair_history_page.dart';

class SelectVehicleForHistoryPage extends StatelessWidget {
  const SelectVehicleForHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select a Vehicle')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('cars')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No vehicles found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? '';
              final model = data['model'] ?? '';
              final kilometers = data['kilometers'] ?? 0;

              return ListTile(
                title: Text('$name $model'),
                subtitle: Text('Kilometers: $kilometers'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RepairHistoryPage(
                        carVin: docs[index].id, // Pass the VIN
                        carName: '${data['name']} ${data['model']}', // For the title
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
