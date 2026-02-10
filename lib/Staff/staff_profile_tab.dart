import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StaffProfileTab extends StatelessWidget {
  const StaffProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                // 🔥 CRITICAL: reset navigation stack
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                      (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
