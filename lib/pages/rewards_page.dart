import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  final double budget;
  final double totalExpense;
  final int totalEntries;

  const RewardsPage({
    super.key,
    required this.budget,
    required this.totalExpense,
    required this.totalEntries,
  });

  @override
  Widget build(BuildContext context) {
    double savings = budget - totalExpense;

    String badge = "";
    Color badgeColor = Colors.grey;

    // 🎖️ Badge Logic
    if (savings >= 3000) {
      badge = "🥇 Gold Saver";
      badgeColor = Colors.amber;
    } else if (savings >= 1000) {
      badge = "🥈 Silver Saver";
      badgeColor = Colors.grey;
    } else if (totalExpense <= budget && budget > 0) {
      badge = "🥉 Bronze Saver";
      badgeColor = Colors.brown;
    } else {
      badge = "❌ No Badge";
      badgeColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rewards"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: badgeColor.withOpacity(0.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Your Monthly Badge",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                badge,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Saved: ₹${savings.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 10),

              Text(
                "Total Spent: ₹${totalExpense.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}