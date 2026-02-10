import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // 🔹 Save / Update User Profile (NO role overwrite)
  static Future<void> saveUserProfile({
    required String name,
    required String email,
    required String role, // citizen / staff
    String? assignedWard,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = _db.collection('users').doc(user.uid);

    await ref.set(
      {
        'uid': user.uid,
        'name': name,
        'email': email,
        'role': role,
        if (assignedWard != null) 'assignedWard': assignedWard,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> addWasteReport({
    required String description,
    required String location,
    required String imageBase64,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('reports').add({
      'userId': user.uid,
      'description': description,
      'location': location,
      'imageBase64': imageBase64,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}