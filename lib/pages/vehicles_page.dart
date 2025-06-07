import 'package:flutter/material.dart';

class VehiclesPage extends StatelessWidget {
  final String name;
  final String model;
  final int kilometers;

  const VehiclesPage({
    Key? key,
    required this.name,
    required this.model,
    required this.kilometers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Health'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My $name $model',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Chip(
                          label: Text('Good'),
                          backgroundColor: Colors.greenAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatusColumn(label: 'Health', value: '85%'),
                        _StatusColumn(label: 'Kilometers', value: kilometers.toString()),
                        _StatusColumn(label: 'Alerts', value: '5'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _ActionButton(icon: Icons.oil_barrel, label: 'Oil Change'),
                _ActionButton(icon: Icons.build, label: 'Add Repair'),
                _ActionButton(icon: Icons.car_repair, label: 'Parts'),
              ],
            ),
            const SizedBox(height: 24),
            // Maintenance Alerts
            const Text(
              'Maintenance Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _AlertCard(
              title: 'Oil Change Due',
              description: 'Last changed 5,200 miles ago',
              color: Colors.yellow,
            ),
            const SizedBox(height: 8),
            _AlertCard(
              title: 'Brake Pads Worn',
              description: 'Estimated 15% remaining',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatusColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const _AlertCard({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.warning, color: color),
        title: Text(title, style: TextStyle(color: color)),
        subtitle: Text(description),
        trailing: Icon(Icons.add_circle, color: color),
      ),
    );
  }
}
