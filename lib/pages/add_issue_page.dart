import 'package:flutter/material.dart';

class AddIssuePage extends StatefulWidget {
  const AddIssuePage({Key? key}) : super(key: key);

  @override
  State<AddIssuePage> createState() => _AddIssuePageState();
}

class _AddIssuePageState extends State<AddIssuePage> {
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = ['Engine', 'Interior', 'Electrical'];

  void _submitIssue() {
    final description = _descriptionController.text.trim();

    if (_selectedCategory == null || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // TODO: Save issue to Firebase here

    Navigator.pop(context); // Close the page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Issue added successfully')),
    );
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
              child: ElevatedButton(
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
