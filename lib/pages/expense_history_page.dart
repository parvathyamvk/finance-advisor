import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class ExpenseHistoryPage extends StatefulWidget {
  final DateTime selectedMonth;

  const ExpenseHistoryPage({
    super.key,
    required this.selectedMonth,
  });

  @override
  State<ExpenseHistoryPage> createState() =>
      _ExpenseHistoryPageState();
}

class _ExpenseHistoryPageState
    extends State<ExpenseHistoryPage> {

  final FirestoreService fs = FirestoreService();
  late DateTime selectedDate;

@override
void initState() {
  super.initState();
  selectedDate = widget.selectedMonth;
}

  String filterType = "Monthly"; // Monthly / Weekly / Daily
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense History"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// FILTER BUTTONS
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [

                _filterButton("Daily"),
                const SizedBox(width: 10),
                _filterButton("Weekly"),
                const SizedBox(width: 10),
                _filterButton("Monthly"),
              ],
            ),

            const SizedBox(height: 20),
          if (filterType == "Daily" || filterType == "Weekly")
  Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: ElevatedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          setState(() {
            selectedDate = picked;
          });
        }
      },
      icon: const Icon(Icons.calendar_today),
      label: Text(
          "Select Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
    ),
  ),
            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('expenses')
                    .where('userId',
                        isEqualTo: fs.uid)
                   // .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                        child:
                            CircularProgressIndicator());
                  }

                  final docs =
                      snapshot.data!.docs;
                  docs.sort((a, b) {
  final da = (a['date'] as Timestamp).toDate();
  final db = (b['date'] as Timestamp).toDate();
  return db.compareTo(da); // newest first
});
                  final filtered =
                      docs.where((doc) {
                    final date =
                        (doc['date'] as Timestamp)
                            .toDate();

                    if (filterType ==
                        "Daily") {
                      return date.year ==
                              selectedDate.year &&
                          date.month ==
                              selectedDate.month &&
                          date.day ==
                              selectedDate.day;
                    }

                    if (filterType ==
                        "Weekly") {
                      final startOfWeek =
                          selectedDate.subtract(
                              Duration(
                                  days:
                                      selectedDate
                                          .weekday -
                                          1));

                      final endOfWeek =
                          startOfWeek.add(
                              const Duration(
                                  days: 6));

                      return date.isAfter(
                              startOfWeek
                                  .subtract(
                                      const Duration(
                                          days:
                                              1))) &&
                          date.isBefore(
                              endOfWeek.add(
                                  const Duration(
                                      days:
                                          1)));
                    }

                    if (filterType ==
                        "Monthly") {
                      return date.year ==
                              selectedDate.year &&
                          date.month ==
                              selectedDate.month;
                    }

                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child:
                          Text("No expenses found"),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder:
                        (context, index) {

                      final data =
                          filtered[index].data();
                      final date =
                          (data['date']
                                  as Timestamp)
                              .toDate();

                      return Dismissible(
                        key: Key(
                            filtered[index]
                                .id),
                        direction:
                            DismissDirection
                                .endToStart,
                        background:
                            Container(
                          alignment:
                              Alignment
                                  .centerRight,
                          padding:
                              const EdgeInsets
                                  .only(
                                      right:
                                          20),
                          color:
                              Colors.red,
                          child:
                              const Icon(
                            Icons.delete,
                            color: Colors
                                .white,
                          ),
                        ),
                        onDismissed:
                            (_) async {
                          await FirebaseFirestore
                              .instance
                              .collection(
                                  'expenses')
                              .doc(filtered[
                                      index]
                                  .id)
                              .delete();
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(
                                "${data['category']} - ₹${data['amount']}"),
                            subtitle: Text(
                                "${date.day}/${date.month}/${date.year}\n${data['note'] ?? ""}"),
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

  Widget _filterButton(String type) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            filterType == type
                ? Colors.indigo
                : Colors.grey[300],
        foregroundColor:
            filterType == type
                ? Colors.white
                : Colors.black,
      ),
      onPressed: () {
        setState(() {
          filterType = type;
        });
      },
      child: Text(type),
    );
  }
}