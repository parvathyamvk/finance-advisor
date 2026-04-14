import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';

class AnalyticsPage extends StatefulWidget {
  final DateTime selectedMonth;

  const AnalyticsPage({
    super.key,
    required this.selectedMonth,
  });

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final FirestoreService fs = FirestoreService();

  DateTime get selectedMonth => widget.selectedMonth;
  final List<Color> pieColors = [
  Colors.indigo,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Analytics"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Monthly Insights",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: StreamBuilder<
                  DocumentSnapshot<Map<String, dynamic>>>(
                stream: fs.budgetStream(selectedMonth),
                builder: (context, budgetSnap) {

                  double monthlyBudget = 0;

                  if (budgetSnap.hasData &&
                      budgetSnap.data!.data() != null) {
                    final data = budgetSnap.data!.data()!;
                    monthlyBudget =
                        (data['monthlyBudget'] ?? 0).toDouble();
                  }

                  return StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: fs.expenseStream(selectedMonth),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      double totalSpent = 0;
                      Map<String, double> categoryTotals = {};
                      Map<int, double> dailyTotals = {};

                      final daysInMonth = DateTime(
                        selectedMonth.year,
                        selectedMonth.month + 1,
                        0,
                      ).day;

                      for (int i = 1; i <= daysInMonth; i++) {
                        dailyTotals[i] = 0;
                      }

                      for (var doc in docs) {
                        final data = doc.data();
                        final amount =
                            (data['amount'] ?? 0).toDouble();
                        final category =
                            data['category'] ?? "Others";
                        final date =
                            (data['date'] as Timestamp).toDate();

                        totalSpent += amount;

                        categoryTotals[category] =
                            (categoryTotals[category] ?? 0) +
                                amount;

                        if (date.month == selectedMonth.month &&
                            date.year == selectedMonth.year) {
                          dailyTotals[date.day] =
                              (dailyTotals[date.day] ?? 0) +
                                  amount;
                        }
                      }
                      // 🔹 Top 3 categories
final sortedCategories = categoryTotals.entries.toList()
  ..sort((a, b) => b.value.compareTo(a.value));

final topCategories = sortedCategories.take(3).toList();
                      
                      int daysPassed = DateTime.now().day;

double avgDaily = 0;
double predictedTotal = 0;
double predictedOver = 0;

if (daysPassed > 0) {
  avgDaily = totalSpent / daysPassed;
  predictedTotal = avgDaily * 30;
  predictedOver = predictedTotal - monthlyBudget;
}

                      return SingleChildScrollView(
                        child: Column(
  children: [
    if (predictedTotal > monthlyBudget)
  Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [

        const Icon(Icons.insights, color: Colors.red),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            "If your current spending continues, you may exceed your budget by ₹${predictedOver.toStringAsFixed(0)} this month.",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  ),
  const SizedBox(height: 25),

Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
      )
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "Top Spending Categories",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 15),

      ...topCategories.asMap().entries.map((entry) {

        final index = entry.key;
        final data = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "${index + 1}. ${data.key} — ₹${data.value.toStringAsFixed(0)}",
            style: const TextStyle(fontSize: 15),
          ),
        );
      }),

      const SizedBox(height: 15),

      if (topCategories.isNotEmpty)
        Text(
          "Suggestion: Reducing ${topCategories.first.key} spending by 20% can save ₹${(topCategories.first.value * 0.2).toStringAsFixed(0)}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.indigo,
          ),
        ),
    ],
  ),
),

    /// SMART RECOMMENDATIONS FIRST
    const Text(
      "Smart Recommendations",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(height: 15),

    
    ...generateRecommendations(
  totalSpent: totalSpent,
  monthlyBudget: monthlyBudget,
  categoryTotals: categoryTotals,
).asMap().entries.map((entry) {

  final index = entry.key;
  final text = entry.value;

  return AnimatedContainer(
    duration: Duration(milliseconds: 400 + (index * 200)),
    curve: Curves.easeOut,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        )
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.lightbulb, color: Colors.amber),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}),

    const SizedBox(height: 30),

    /// PIE CHART
    Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// PIE CHART
    SizedBox(
      height: 250,
      width: 250,
      child: PieChart(
        PieChartData(
          sections: categoryTotals.entries
              .toList()
              .asMap()
              .entries
              .map((entry) {

            final index = entry.key;
            final e = entry.value;

            final _ = (e.value / totalSpent) * 100;

            return PieChartSectionData(
              value: e.value,
              color: pieColors[index % pieColors.length],
              title: "",
              radius: 90,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 3,
          centerSpaceRadius: 40,
        ),
      ),
    ),

    const SizedBox(width: 30),

    /// LEGEND (CATEGORY LIST)
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryTotals.entries
          .toList()
          .asMap()
          .entries
          .map((entry) {

        final index = entry.key;
        final e = entry.value;

        final percent = (e.value / totalSpent) * 100;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [

              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: pieColors[index % pieColors.length],
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 8),

              Text(
                "${e.key} (${percent.toStringAsFixed(1)}%)",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  ],
),

    const SizedBox(height: 30),

    /// BAR CHART
    Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardStyle(),
      child: Column(
        children: [
          const Text(
            "Daily Spending",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: daysInMonth * 40,
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(
                    daysInMonth,
                    (index) {
                      final day = index + 1;
                      final value =
                          dailyTotals[day] ?? 0;

                      return BarChartGroupData(
                        x: day,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            width: 12,
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// RECOMMENDATION LOGIC
  List<String> generateRecommendations({
    required double totalSpent,
    required double monthlyBudget,
    required Map<String, double> categoryTotals,
  }) {
    List<String> suggestions = [];

    if (monthlyBudget > 0 &&
        totalSpent > monthlyBudget) {
      suggestions.add(
          "⚠ You exceeded your monthly budget.");
    }

    if (monthlyBudget > 0 &&
        totalSpent < monthlyBudget * 0.6) {
      suggestions.add(
          "✅ Great budget control this month!");
    }

    if (categoryTotals.isNotEmpty) {
      final highest = categoryTotals.entries
          .reduce((a, b) =>
              a.value > b.value ? a : b);

      suggestions.add(
          "💡 Most spending is on ${highest.key}. Try reducing it next month.");
    }

    final savings = monthlyBudget - totalSpent;
    if (savings > 0) {
      suggestions.add(
          "📈 You saved ₹${savings.toStringAsFixed(0)} this month.");
    }

    return suggestions;
  }

  BoxDecoration _cardStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        )
      ],
    );
  }
}