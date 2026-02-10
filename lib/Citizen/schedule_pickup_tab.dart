import 'package:flutter/material.dart';

class SchedulePickupTab extends StatelessWidget {
  const SchedulePickupTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Pickup')),
      body: const Center(
        child: Text(
          'Schedule waste pickup 🚛',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
