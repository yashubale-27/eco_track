import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'Citizen/citizen_login_page.dart';
import 'Citizen/citizen_dashboard.dart';
import 'Staff/staff_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EcoTrackApp());
}

class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoTrack',
      home: const RoleGate(),
    );
  }
}
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1️⃣ Not logged in
        if (!authSnapshot.hasData) {
          return const CitizenLoginPage();
        }

        final user = authSnapshot.data!;

        // 2️⃣ Logged in → fetch role
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'];

            if (role == 'staff') {
              return const StaffDashboard();
            } else {
              return const CitizenDashboard();
            }
          },
        );
      },
    );
  }
}

