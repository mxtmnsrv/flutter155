import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddIssuePage extends StatefulWidget {
  final String carVin; // Add this to know which car the issue belongs to

  const AddIssuePage({Key? key, required this.carVin}) : super(key: key);

  @override
  State<AddIssuePage> createState() => _AddIssuePageState();
}

class _AddIssuePageState extends State<AddIssuePage> {
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  final List<String> _categories = ['Engine', 'Interior', 'Electrical'];

  Future<void> _submitIssue() async {
    final description = _descriptionController.text.trim();

    if (_selectedCategory == null || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      // Create issue data
      final issueData = {
        'category': _selectedCategory,
        'description': description,
        'date': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      // Save to Firestore under Users > uid > cars > carVin > issues
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('cars')
          .doc(widget.carVin)
          .collection('issues')
          .add(issueData);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue added successfully')),
      );
    } catch (e) {
      print("Error adding issue: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add issue: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Issue')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category'),
            DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              isExpanded: true,
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Description'),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the issue',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitIssue,
                      child: const Text('Submit'),
                    ),
            )
          ],
        ),
      ),
    );
  }
}