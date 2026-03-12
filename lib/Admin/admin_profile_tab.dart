import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Logged in as:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              user?.email ?? "No Email",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),

              onPressed: () async {

                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}