import 'package:flutter/material.dart';
import 'admin_reports_tab.dart';
import 'admin_stats_tab.dart';
import 'admin_profile_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  int currentIndex = 0;

  final pages = const [
    AdminStatsTab(),
    AdminReportsTab(),
    AdminProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        selectedItemColor: Colors.green,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Stats",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Reports",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}