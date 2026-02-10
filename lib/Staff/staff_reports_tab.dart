import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffReportsTab extends StatelessWidget {
  const StaffReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!.docs;

        if (reports.isEmpty) {
          return const Center(child: Text('No reports yet'));
        }

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final data = reports[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(
                  Icons.delete,
                  color: data['status'] == 'pending'
                      ? Colors.red
                      : Colors.green,
                ),
                title: Text(data['description'] ?? 'No description'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Location: ${data['location']}"),
                    Text("Status: ${data['status']}"),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: data['status'] == 'pending'
                      ? () {
                    FirebaseFirestore.instance
                        .collection('reports')
                        .doc(reports[index].id)
                        .update({
                      'status': 'assigned',
                    });
                  }
                      : null,
                  child: const Text('Assign'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
