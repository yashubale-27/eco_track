import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffReportsTab extends StatelessWidget {
  const StaffReportsTab({super.key});

  Future<void> openGoogleMaps(double lat, double lng) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pending reports'));
        }

        final reports = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {

            final data =
            reports[index].data() as Map<String, dynamic>;

            final createdAt =
            (data['createdAt'] as Timestamp).toDate();

            final difference =
            DateTime.now().difference(createdAt);

            final isDelayed = difference.inMinutes > 30;

            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      data['description'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text("Location: ${data['locationName']}"),

                    if (isDelayed)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "⚠ Ignored for 30+ mins",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        IconButton(
                          icon: const Icon(Icons.navigation),
                          onPressed: () {
                            openGoogleMaps(
                              data['latitude'],
                              data['longitude'],
                            );
                          },
                        ),

                        ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('reports')
                                .doc(reports[index].id)
                                .update({
                              'status': 'assigned',
                              'assignedStaffId': staffUid,
                              'assignedAt': Timestamp.now(),
                            });
                          },
                          child: const Text("Assign"),
                        ),
                      ],
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