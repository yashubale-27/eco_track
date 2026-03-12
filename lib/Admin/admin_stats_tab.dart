import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStatsTab extends StatefulWidget {
  const AdminStatsTab({super.key});

  @override
  State<AdminStatsTab> createState() => _AdminStatsTabState();
}

class _AdminStatsTabState extends State<AdminStatsTab> {

  int pending = 0;
  int assigned = 0;
  int completed = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {

    try {

      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .get();

      int p = 0;
      int a = 0;
      int c = 0;

      for (var doc in snapshot.docs) {

        final data = doc.data();
        final status = data['status'];

        if (status == 'pending') p++;
        if (status == 'assigned') a++;
        if (status == 'completed') c++;
      }

      setState(() {
        pending = p;
        assigned = a;
        completed = c;
        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      debugPrint("Error loading stats: $e");
    }
  }

  Widget statCard(String title, int count, Color color) {

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),

      child: ListTile(
        leading: Icon(Icons.bar_chart, color: color),

        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),

        trailing: Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [

          statCard("Pending Complaints", pending, Colors.orange),

          statCard("Assigned Tasks", assigned, Colors.blue),

          statCard("Completed Cleanups", completed, Colors.green),
        ],
      ),
    );
  }
}