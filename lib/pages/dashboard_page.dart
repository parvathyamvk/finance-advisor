import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'add_expense_page.dart';
import 'expense_history_page.dart';
import 'analytics_page.dart';
import 'category_budget_page.dart';
import 'rewards_page.dart';  

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirestoreService fs = FirestoreService();
  final AuthService auth = AuthService();

  DateTime selectedMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  

  final TextEditingController budgetController =
      TextEditingController();
  final TextEditingController dailyController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fs.ensureCategoryCarryForward(selectedMonth);
  }

  String monthName(DateTime date) {
    return "${date.year} - ${date.month.toString().padLeft(2, '0')}";
  }

  void changeMonth(int offset) async {
    final newMonth =
        DateTime(selectedMonth.year, selectedMonth.month + offset);

    setState(() {
      selectedMonth = newMonth;
      selectedDate =
          DateTime(newMonth.year, newMonth.month, 1);
    });

    await fs.ensureCategoryCarryForward(newMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: const Text("Finance Advisor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AnalyticsPage(
  selectedMonth: selectedMonth,
),),
              );
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CategoryBudgetPage(
                    selectedMonth: selectedMonth,
),),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          changeMonth(-1),
                      icon: const Icon(
                          Icons.arrow_back_ios),
                    ),
                    Text(
                      monthName(selectedMonth),
                      style:
                          const TextStyle(
                              fontWeight:
                                  FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () =>
                          changeMonth(1),
                      icon: const Icon(
                          Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// DATE SELECTOR
            Row(
              children: [
                const Text(
                  "Selected Date: ",
                  style: TextStyle(
                      fontWeight:
                          FontWeight.w600),
                ),
                Text(
                  "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                  style: const TextStyle(
                      color: Colors.indigo),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    final firstDay =
                        DateTime(selectedMonth.year,
                            selectedMonth.month, 1);

                    final lastDay =
                        DateTime(selectedMonth.year,
                            selectedMonth.month + 1,
                            0);

                    final picked =
                        await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: firstDay,
                      lastDate: lastDay,
                    );

                    if (picked != null) {
                      setState(() {
                        selectedDate =
                            picked;
                      });
                    }
                  },
                  child:
                      const Text("Change Date"),
                )
              ],
            ),
 
            const SizedBox(height: 20),

            Expanded(
              child:
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream:
                    fs.budgetStream(
                        selectedMonth),
                builder:
                    (context, budgetSnap) {

                  double monthlyBudget = 0;
                  double dailyLimit = 0;

                  if (budgetSnap.hasData &&
                      budgetSnap.data!
                              .data() !=
                          null) {
                    final data =
                        budgetSnap.data!
                            .data()!;
                    monthlyBudget =
                        (data['monthlyBudget'] ??
                                0)
                            .toDouble();
                    dailyLimit =
                        (data['dailyLimit'] ??
                                0)
                            .toDouble();
                  }

                  return StreamBuilder<
                      QuerySnapshot<
                          Map<String,
                              dynamic>>>(
                    stream:
                        fs.expenseStream(
                            selectedMonth),
                    builder:
                        (context, expSnap) {

                      if (!expSnap.hasData) {
                        return const Center(
                            child:
                                CircularProgressIndicator());
                      }

                      final docs =
                          expSnap.data!.docs;

                      double totalSpent = 0;
                      double selectedDaySpent = 0;

                      Map<String, double>
                          categoryTotals =
                          {};

                      for (var doc
                          in docs) {
                        final data =
                            doc.data();
                        final amount =
                            (data['amount'] ??
                                    0)
                                .toDouble();
                        final date =
                            (data['date']
                                    as Timestamp)
                                .toDate();
                        final category =
                            data['category'] ??
                                "Others";

                        totalSpent +=
                            amount;

                        if (date.year ==
                                selectedDate
                                    .year &&
                            date.month ==
                                selectedDate
                                    .month &&
                            date.day ==
                                selectedDate
                                    .day) {
                          selectedDaySpent +=
                              amount;
                        }

                        categoryTotals[
                                category] =
                            (categoryTotals[
                                        category] ??
                                    0) +
                                amount;
                      }
                      int daysPassed = DateTime.now().day;

double spendingSpeed = 0;
double expectedDaily = 0;

if (monthlyBudget > 0 && daysPassed > 0) {
  spendingSpeed = totalSpent / daysPassed;
  expectedDaily = monthlyBudget / 30;
}

bool highSpendingSpeed = spendingSpeed > expectedDaily;
                      String topCategory = "";
double topAmount = 0;

if (categoryTotals.isNotEmpty) {
  final highest = categoryTotals.entries
      .reduce((a, b) => a.value > b.value ? a : b);

  topCategory = highest.key;
  topAmount = highest.value;
}

                      final remaining =
                          monthlyBudget -
                              totalSpent;

                      return SingleChildScrollView(
                        child: Column(
                          children: [

                            /// BUDGET INPUT
                            Card(
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),
                              child:
                                  Padding(
                                padding:
                                    const EdgeInsets.all(
                                        20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child:
                                          TextField(
                                        controller:
                                            budgetController,
                                        keyboardType:
                                            TextInputType.number,
                                        decoration:
                                            const InputDecoration(
                                          labelText:
                                              "Monthly Budget",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            20),
                                    Expanded(
                                      child:
                                          TextField(
                                        controller:
                                            dailyController,
                                        keyboardType:
                                            TextInputType.number,
                                        decoration:
                                            const InputDecoration(
                                          labelText:
                                              "Daily Limit",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            20),
                                    ElevatedButton(
                                      onPressed:
                                          () async {
                                        final budget =
                                            double.tryParse(
                                                    budgetController.text) ??
                                                0;
                                        final daily =
                                            double.tryParse(
                                                    dailyController.text) ??
                                                0;

                                        await fs
                                            .saveBudget(
                                          month:
                                              selectedMonth,
                                          monthlyBudget:
                                              budget,
                                          dailyLimit:
                                              daily,
                                        );
                                      },
                                      child:
                                          const Text(
                                              "Save"),
                                    )
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 25),

                            /// STAT CARDS
                            Row(
                              children: [
                                _statCard(
                                    "Monthly Budget",
                                    monthlyBudget,
                                    Colors
                                        .indigo),
                                const SizedBox(
                                    width: 15),
                                _statCard(
                                    "Total Spent",
                                    totalSpent,
                                    Colors.red),
                                const SizedBox(
                                    width: 15),
                                _statCard(
                                    "Remaining",
                                    remaining,
                                    Colors.green),
                              ],
                            ),
                            const SizedBox(height: 15),
const SizedBox(height: 20),

Row(
  children: [

    /// ➕ ADD EXPENSE
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpensePage(
                selectedDate: selectedDate,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Expense"),
      ),
    ),

    const SizedBox(width: 15),

    /// 🎁 REWARDS
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RewardsPage(
                budget: monthlyBudget,
                totalExpense: totalSpent,
                totalEntries: docs.length,
              ),
            ),
          );
        },
        icon: const Icon(Icons.card_giftcard),
        label: const Text("Rewards"),
      ),
    ),

    const SizedBox(width: 15),

    /// 📜 EXPENSE HISTORY
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExpenseHistoryPage(
                selectedMonth: selectedMonth,
              ),
            ),
          );
        },
        icon: const Icon(Icons.history),
        label: const Text("History"),
      ),
    ),
  ],
),

const SizedBox(height: 20),
                            const SizedBox(height: 20),

if (highSpendingSpeed)
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [

        const Icon(Icons.warning, color: Colors.orange),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            "You are spending faster than expected this month.",
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
        "Top Spending Category",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 10),

      Text(
        topCategory,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),

      Text(
        "₹${topAmount.toStringAsFixed(0)}",
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    ],
  ),
),
                            const SizedBox(
                                height: 25),

                                  
                                
                              

                            const SizedBox(
                                height: 25),

                            /// DAILY LIMIT
                            if (dailyLimit >
                                0)
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  const Text(
                                    "Daily Limit",
                                    style:
                                        TextStyle(
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          10),

                                  Builder(
                                    builder:
                                        (_) {
                                      final percent =
                                          selectedDaySpent /
                                              dailyLimit;

                                      Color
                                          barColor;

                                      if (percent >=
                                          1) {
                                        barColor =
                                            Colors.red;
                                      } else if (percent >=
                                          0.8) {
                                        barColor =
                                            Colors.orange;
                                      } else {
                                        barColor =
                                            Colors.green;
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [

                                          Text(
                                            "₹${selectedDaySpent.toStringAsFixed(0)} / ₹${dailyLimit.toStringAsFixed(0)}",
                                            style:
                                                TextStyle(
                                              color:
                                                  barColor,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(
                                              height:
                                                  8),

                                          LinearProgressIndicator(
                                            value:
                                                percent.clamp(0.0, 1.0),
                                            backgroundColor:
                                                Colors.grey[200],
                                            color:
                                                barColor,
                                          ),

                                          const SizedBox(
                                              height:
                                                  20),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),

                            const SizedBox(
                                height: 30),

                            /// CATEGORY LIMITS
                            StreamBuilder<
                                QuerySnapshot<
                                    Map<String,
                                        dynamic>>>(
                              stream: fs
                                  .categoryBudgetStream(
                                      selectedMonth),
                              builder:
                                  (context,
                                      catSnap) {

                                if (!catSnap
                                        .hasData ||
                                    catSnap.data!
                                        .docs
                                        .isEmpty) {
                                  return const SizedBox();
                                }

                                final categoryDocs =
                                    catSnap.data!
                                        .docs;

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [

                                    const Text(
                                      "Category Limits",
                                      style:
                                          TextStyle(
                                        fontSize:
                                            18,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                            15),

                                    ...categoryDocs
                                        .map(
                                            (doc) {

                                      final data =
                                          doc.data();
                                      final category =
                                          data[
                                              'category'];
                                      final limit =
                                          (data['limit'] ??
                                                  0)
                                              .toDouble();

                                      final spent =
                                          categoryTotals[
                                                  category] ??
                                              0;

                                      final percent =
                                          limit ==
                                                  0
                                              ? 0
                                              : spent /
                                                  limit;

                                      Color
                                          barColor;

                                      if (percent >=
                                          1) {
                                        barColor =
                                            Colors.red;
                                      } else if (percent >=
                                          0.8) {
                                        barColor =
                                            Colors.orange;
                                      } else {
                                        barColor =
                                            Colors.green;
                                      }

                                      return Container(
                                        margin:
                                            const EdgeInsets.only(
                                                bottom:
                                                    15),
                                        padding:
                                            const EdgeInsets.all(
                                                18),
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Colors
                                                  .white,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  0.05),
                                              blurRadius:
                                                  20,
                                            )
                                          ],
                                        ),
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  category,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}",
                                                  style: TextStyle(
                                                      color:
                                                          barColor),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(
                                                height:
                                                    8),

                                            LinearProgressIndicator(
                                                  value: percent.clamp(0.0, 1.0).toDouble(),
                                              backgroundColor:
                                                  Colors.grey[
                                                      200],
                                              color:
                                                  barColor,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                );
                                
                              },
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

  Widget _statCard(
    String title,
    double value,
    Color color) {

  IconData icon;

  if (title == "Monthly Budget") {
    icon = Icons.account_balance_wallet;
  } else if (title == "Total Spent") {
    icon = Icons.trending_down;
  } else {
    icon = Icons.savings;
  }

  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.85),
            color.withOpacity(0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Icon(
                icon,
                color: Colors.white,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "₹${value.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
}