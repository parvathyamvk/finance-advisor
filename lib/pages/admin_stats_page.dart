import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStatsPage extends StatelessWidget {
  const AdminStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("System Analytics 📊")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: Future.wait([
            FirebaseFirestore.instance.collection('users').get(),
            FirebaseFirestore.instance.collection('expenses').get(),
            FirebaseFirestore.instance.collection('category_budgets').get(),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data![0].docs.length;
            final expenses = snapshot.data![1].docs.length;
            final categories = snapshot.data![2].docs.length;

            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.8,
              children: [

                _statCard("Total Users", users.toString(), Icons.people, Colors.blue),

                _statCard("Total Expenses", expenses.toString(), Icons.money, Colors.green),

                _statCard("Categories", categories.toString(), Icons.category, Colors.orange),

                _statCard("System Health", "Good", Icons.check_circle, Colors.purple),

              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}