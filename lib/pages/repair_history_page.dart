import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RepairHistoryPage extends StatelessWidget {
  final String carVin;
  final String carName;

  const RepairHistoryPage({
    required this.carVin,
    required this.carName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Not logged in")));

    return Scaffold(
      appBar: AppBar(title: Text('Repair History: $carName')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('cars')
            .doc(carVin)
            .collection('issues')
            .where('status', isEqualTo: 'resolved')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Handle connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle empty data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No resolved issues found.'));
          }

          // Display the list
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final issue = doc.data() as Map<String, dynamic>;
              
              // Safely parse the date
              String formattedDate = 'Date not available';
              try {
                final date = DateTime.parse(issue['date']).toLocal();
                formattedDate = 'Resolved on ${date.toString().split(' ')[0]}';
              } catch (e) {
                debugPrint('Error parsing date: $e');
              }

              return ListTile(
                title: Text(issue['category'] ?? 'No category'),
                subtitle: Text(issue['description'] ?? 'No description'),
                trailing: Text(formattedDate),
              );
            },
          );
        },
      ),
    );
  }
}