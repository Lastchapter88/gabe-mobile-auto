import 'package:flutter/material.dart';

class SystemMonitorScreen extends StatelessWidget {
  const SystemMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Monitor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard('API Status', 'Online', Colors.green),
          _buildStatusCard('Database', 'Connected', Colors.green),
          _buildStatusCard('Storage', 'Available', Colors.green),
          _buildStatusCard('Notifications', 'Active', Colors.blue),
          const Divider(),
          const ListTile(
            title: Text('Recent Logs'),
            subtitle: Text('No critical errors in last 24h'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.circle, color: color),
        title: Text(title),
        trailing: Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
