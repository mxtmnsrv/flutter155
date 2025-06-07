import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({Key? key}) : super(key: key);

  @override
  _AddVehiclePageState createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _kilometersController = TextEditingController();

  bool _isLoading = false;

  Future<void> _addVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      final carData = {
        'vin': _vinController.text.trim(),
        'name': _nameController.text.trim(),
        'model': _modelController.text.trim(),
        'year': int.parse(_yearController.text.trim()),
        'kilometers': int.parse(_kilometersController.text.trim()),
      };

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('cars')
          .doc(_vinController.text.trim()) // use VIN as doc ID
          .set(carData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error adding vehicle: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vehicle: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _vinController.dispose();
    _nameController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _kilometersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(labelText: 'VIN'),
                validator: (value) => value!.isEmpty ? 'Enter VIN' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Brand (Toyota, BMW...)'),
                validator: (value) => value!.isEmpty ? 'Enter brand name' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model (X5, Camry...)'),
                validator: (value) => value!.isEmpty ? 'Enter model' : null,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter year' : null,
              ),
              TextFormField(
                controller: _kilometersController,
                decoration: const InputDecoration(labelText: 'Kilometers'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter kilometers' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _addVehicle,
                      child: const Text('Save Vehicle'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
