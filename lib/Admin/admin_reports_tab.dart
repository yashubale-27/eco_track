import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .snapshots(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!.docs;

        return ListView.builder(

          itemCount: reports.length,

          itemBuilder: (context, index) {

            final data = reports[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(10),

              child: ListTile(
                title: Text(data['description'] ?? ""),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text("Location: ${data['locationName'] ?? ""}"),

                    Text("Status: ${data['status']}"),
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