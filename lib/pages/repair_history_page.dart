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
            //.where('status', isEqualTo: 'pending') // Only resolved issues
            .orderBy('date', descending: true) // Newest first
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No resolved issues yet.'));

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final issue = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(issue['category']),
                subtitle: Text(issue['description']),
                trailing: Text(
                  'Resolved on ${DateTime.parse(issue['date']).toLocal().toString().split(' ')[0]}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}