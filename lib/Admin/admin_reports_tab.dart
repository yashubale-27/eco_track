import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});

  Widget buildImage(String base64String) {
    Uint8List bytes = base64Decode(base64String);

    return Image.memory(
      bytes,
      height: 120,
      width: 120,
      fit: BoxFit.cover,
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

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

        int pending = 0;
        int assigned = 0;
        int completed = 0;

        for (var doc in reports) {
          final status = doc['status'];

          if (status == 'pending') pending++;
          if (status == 'assigned') assigned++;
          if (status == 'completed') completed++;
        }

        return Column(
          children: [

            /// STATISTICS
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  statCard("Pending", pending, Colors.orange),
                  statCard("Assigned", assigned, Colors.blue),
                  statCard("Completed", completed, Colors.green),
                ],
              ),
            ),

            const Divider(),

            /// REPORT LIST
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,

                itemBuilder: (context, index) {

                  final data =
                  reports[index].data() as Map<String, dynamic>;

                  final beforeImage = data['beforeImage'];
                  final afterImage = data['afterImage'];
                  final status = data['status'];

                  return Card(
                    margin: const EdgeInsets.all(10),

                    child: ExpansionTile(

                      title: Text(
                        data['description'] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        children: [

                          Expanded(
                            child: Text(
                              "Location: ${data['locationName'] ?? ""}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),

                            decoration: BoxDecoration(
                              color: getStatusColor(status),
                              borderRadius: BorderRadius.circular(6),
                            ),

                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      children: [

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,

                          children: [

                            /// BEFORE IMAGE
                            Column(
                              children: [

                                const Text(
                                  "Before",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 6),

                                if (beforeImage != null)
                                  buildImage(beforeImage)
                                else
                                  const Text("No Image"),
                              ],
                            ),

                            /// AFTER IMAGE
                            Column(
                              children: [

                                const Text(
                                  "After",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 6),

                                if (afterImage != null)
                                  buildImage(afterImage)
                                else
                                  const Text("Not cleaned yet"),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget statCard(String title, int count, Color color) {

    return Card(
      elevation: 3,

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}