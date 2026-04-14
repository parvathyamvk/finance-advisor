import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryBudgetPage extends StatefulWidget {
  final DateTime selectedMonth;

  const CategoryBudgetPage({
    super.key,
    required this.selectedMonth,
  });

  @override
  State<CategoryBudgetPage> createState() =>
      _CategoryBudgetPageState();
}
class _CategoryBudgetPageState
    extends State<CategoryBudgetPage> {

  final FirestoreService fs = FirestoreService();
  final TextEditingController amountCtrl =
      TextEditingController();

  String selectedCategory = "Food";

  final List<String> categories = [
    "Food",
    "Travel",
    "Shopping",
    "Snacks",
    "Others"
  ];

  Future<void> save() async {
    final limit =
        double.tryParse(amountCtrl.text) ?? 0;

    if (limit <= 0) return;

    await fs.saveCategoryBudget(
  month: widget.selectedMonth,
  category: selectedCategory,
  amount: limit,
);

    amountCtrl.clear();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
          content: Text("Budget Saved ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar:
          AppBar(title: const Text("Category Budgets")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [

            /// INPUT CARD
            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.05),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Row(
                children: [

                  Expanded(
                    child:
                        DropdownButtonFormField(
                      value: selectedCategory,
                      items: categories
                          .map(
                            (e) =>
                                DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() =>
                            selectedCategory =
                                val!);
                      },
                      decoration:
                          const InputDecoration(
                              labelText:
                                  "Category"),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: TextField(
                      controller:
                          amountCtrl,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "Limit (₹)",
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  ElevatedButton(
                    onPressed: save,
                    child:
                        const Text("Save"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// LIST OF CATEGORY LIMITS
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: fs.categoryBudgetStream(widget.selectedMonth),
                builder:
                    (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                        child:
                            CircularProgressIndicator());
                  }

                  final docs =
                      snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                        child: Text(
                            "No category budgets set"));
                  }

                  return ListView.builder(
                    itemCount:
                        docs.length,
                    itemBuilder:
                        (context, index) {

                      final data =
                          docs[index]
                              .data();

                      return Card(
                        child: ListTile(
                          title: Text(
                              data['category']),
                          trailing: Text(
                            "₹ ${data['limit']}",
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}