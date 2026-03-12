import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_helper.dart';

class StaffPickupsTab extends StatefulWidget {
  const StaffPickupsTab({super.key});

  @override
  State<StaffPickupsTab> createState() => _StaffPickupsTabState();
}

class _StaffPickupsTabState extends State<StaffPickupsTab> {

  final ImagePicker _picker = ImagePicker();

  Map<String, File?> cleanupImages = {};

  // 📷 Capture cleanup image
  Future<void> captureCleanupImage(String docId) async {

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (picked != null) {

      setState(() {
        cleanupImages[docId] = File(picked.path);
      });
    }
  }

  // ✅ Mark complaint completed
  Future<void> markCompleted(String docId) async {

    if (cleanupImages[docId] == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please take cleanup photo")),
      );

      return;
    }

    try {

      final compressedImage =
      await ImageHelper.compressImage(cleanupImages[docId]!);

      await FirebaseFirestore.instance
          .collection('reports')
          .doc(docId)
          .update({

        'status': 'completed',
        'afterImage': compressedImage,
        'completedAt': Timestamp.now(),

      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marked as completed")),
      );

      setState(() {
        cleanupImages.remove(docId);
      });

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

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
            final docId = docs[index].id;

            return Card(
              margin: const EdgeInsets.all(10),

              child: Padding(
                padding: const EdgeInsets.all(10),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      data['description'] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text("Location: ${data['locationName'] ?? ""}"),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () => captureCleanupImage(docId),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Take Cleanup Photo"),
                    ),

                    const SizedBox(height: 10),

                    if (cleanupImages[docId] != null)
                      Image.file(
                        cleanupImages[docId]!,
                        height: 150,
                        fit: BoxFit.cover,
                      ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () => markCompleted(docId),
                      child: const Text("Mark Done"),
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