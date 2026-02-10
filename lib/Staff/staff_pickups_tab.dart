import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffPickupsTab extends StatelessWidget {
  const StaffPickupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .where('status', isEqualTo: 'assigned')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('No assigned pickups'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(data['description']),
                subtitle: Text("Location: ${data['location']}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('reports')
                        .doc(docs[index].id)
                        .update({
                      'status': 'completed',
                    });
                  },
                  child: const Text('Mark Done'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
