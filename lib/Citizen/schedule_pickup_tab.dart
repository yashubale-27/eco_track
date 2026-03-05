import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchedulePickupTab extends StatelessWidget {
  const SchedulePickupTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('status', whereIn: ['assigned', 'completed'])
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No assigned pickups yet'),
          );
        }

        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {

            final data =
            reports[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(
                  Icons.local_shipping,
                  color: data['status'] == 'completed'
                      ? Colors.green
                      : Colors.orange,
                ),
                title: Text(data['description'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text("Location: ${data['locationName']}"),
                    Text(
                      "Status: ${data['status']}",
                      style: TextStyle(
                        color: data['status'] ==
                            'completed'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}