import 'package:flutter/material.dart';
import 'admin_users_page.dart';
import 'admin_stats_page.dart';
import 'admin_category_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel 👑"),
        centerTitle: true,
      ),

      body: Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 900), // 🔥 LIMIT WIDTH
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8, // 🔥 REDUCE HEIGHT

        children: [

          _buildCard(
            context,
            "Users",
            Icons.people,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUsersPage()),
              );
            },
          ),

          _buildCard(
            context,
            "System Stats",
            Icons.bar_chart,
            Colors.green,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminStatsPage()),
              );
            },
          ),

          _buildCard(
            context,
            "Categories",
            Icons.category,
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminCategoryPage(),
                  
                ),
              );
            },
          ),

          _buildCard(
            context,
            "Logout",
            Icons.logout,
            Colors.red,
            () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  ),
),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}