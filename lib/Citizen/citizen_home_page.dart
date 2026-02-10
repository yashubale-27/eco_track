import 'package:flutter/material.dart';

class CitizenHomePage extends StatelessWidget {
  const CitizenHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citizen Dashboard')),
      body: const Center(
        child: Text('Welcome Citizen 👋'),
      ),
    );
  }
}
