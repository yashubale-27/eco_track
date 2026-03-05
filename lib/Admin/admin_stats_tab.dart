import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStatsTab extends StatelessWidget {
  const AdminStatsTab({super.key});

  Future<Map<String, int>> fetchStats() async {

    final reports = await FirebaseFirestore.instance
        .collection('reports')
        .get();

    int pending = 0;
    int assigned = 0;
    int completed = 0;

    for (var doc in reports.docs) {

      final status = doc['status'];

      if (status == 'pending') pending++;
      if (status == 'assigned') assigned++;
      if (status == 'completed') completed++;
    }

    return {
      "pending": pending,
      "assigned": assigned,
      "completed": completed
    };
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: fetchStats(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              _card("Pending Complaints", stats['pending']!, Colors.orange),

              const SizedBox(height: 20),

              _card("Assigned Tasks", stats['assigned']!, Colors.blue),

              const SizedBox(height: 20),

              _card("Completed Cleanups", stats['completed']!, Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _card(String title, int count, Color color) {

    return Card(
      child: ListTile(
        leading: Icon(Icons.bar_chart, color: color),
        title: Text(title),
        trailing: Text(
          count.toString(),
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}