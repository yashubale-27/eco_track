import 'package:flutter/material.dart';
import 'admin_reports_tab.dart';
import 'admin_stats_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  int index = 0;

  final pages = const [
    AdminStatsTab(),
    AdminReportsTab(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),

      body: pages[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Stats",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Reports",
          ),
        ],
      ),
    );
  }
}