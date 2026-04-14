import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  String monthKey(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}";

  // Save Monthly Budget
  Future<void> saveBudget({
    required DateTime month,
    required double monthlyBudget,
    required double dailyLimit,
  }) async {
    final key = monthKey(month);

    await _db.collection('budgets').doc("$uid-$key").set({
      'userId': uid,
      'month': key,
      'monthlyBudget': monthlyBudget,
      'dailyLimit': dailyLimit,
    });
  }

  // Stream Monthly Budget
  Stream<DocumentSnapshot<Map<String, dynamic>>> budgetStream(
      DateTime month) {
    final key = monthKey(month);
    return _db.collection('budgets').doc("$uid-$key").snapshots();
  }

  // Add Expense

  

  // Stream Month Expenses
  Stream<QuerySnapshot<Map<String, dynamic>>> expenseStream(
    DateTime month) {

  final key = monthKey(month);

  return _db
      .collection('expenses')
      .where('userId', isEqualTo: uid)
      .where('month', isEqualTo: key)
      .snapshots();
}
    Future<void> addExpense({
  required double amount,
  required String category,
  required String note,
  required DateTime date,
  String location = "Unknown",// ✅ ADD THIS
}) async {
    final key = monthKey(date);

    await _db.collection('expenses').add({
      'userId': uid,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date,
      'month': key,
      'location': location, // ✅ ADD THIS
    });
  }

  // 🔥 ADD THIS METHOD BELOW addExpense
  Future<void> applyRecurringExpenses() async {
    final recurring = await _db
        .collection('recurring_expenses')
        .where('userId', isEqualTo: uid)
        .get();
print("Recurring count: ${recurring.docs.length}");
    final now = DateTime.now();
    final currentMonth = monthKey(now);

    for (var doc in recurring.docs) {
      final data = doc.data();

      final amount = (data['amount'] ?? 0).toDouble();
      final category = data['category'];
      final note = data['note'];
      final frequency = data['frequency'];

      if (frequency == "monthly") {
        final existing = await _db
            .collection('expenses')
            .where('userId', isEqualTo: uid)
            .where('category', isEqualTo: category)
            .where('note', isEqualTo: note)
            .where('month', isEqualTo: currentMonth)
            .get();

        if (existing.docs.isEmpty) {
          await addExpense(
            amount: amount,
            category: category,
            note: note,
            date: now,
          );
        }
      }

      if (frequency == "weekly") {
        final startOfWeek =
            now.subtract(Duration(days: now.weekday - 1));

        final existing = await _db
            .collection('expenses')
            .where('userId', isEqualTo: uid)
            .where('category', isEqualTo: category)
            .where('note', isEqualTo: note)
            .where('date',
                isGreaterThanOrEqualTo: startOfWeek)
            .get();

        if (existing.docs.isEmpty) {
          await addExpense(
            amount: amount,
            category: category,
            note: note,
            date: now,
          );
        }
      }
    }
  }
  // Save category budget
Future<void> saveCategoryBudget({
  required DateTime month,
  required String category,
  required double amount,
}) async {

  final key = monthKey(month);

  await _db
      .collection('category_budgets')
      .doc("$uid-$key-$category")
      .set({
    'userId': uid,
    'month': key,
    'category': category,
    'limit': amount,
  });
}

// Stream category budgets
Stream<QuerySnapshot<Map<String, dynamic>>> 
    categoryBudgetStream(DateTime month) {

  final key = monthKey(month);

  return _db
      .collection('category_budgets')
      .where('userId', isEqualTo: uid)
      .where('month', isEqualTo: key)
      .snapshots();
}
Future<void> ensureCategoryCarryForward(DateTime month) async {
  try {
    final key = monthKey(month);

    final existing = await _db
        .collection('category_budgets')
        .where('userId', isEqualTo: uid)
        .where('month', isEqualTo: key)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    final prevMonth =
        DateTime(month.year, month.month - 1);

    final prevKey = monthKey(prevMonth);

    final previousDocs = await _db
        .collection('category_budgets')
        .where('userId', isEqualTo: uid)
        .where('month', isEqualTo: prevKey)
        .get();

    for (var doc in previousDocs.docs) {
      final data = doc.data();

      await _db
          .collection('category_budgets')
          .doc("$uid-$key-${data['category']}")
          .set({
        'userId': uid,
        'month': key,
        'category': data['category'],
        'limit': data['limit'],
      });
    }
  } catch (e) {
    print("Carry forward error: $e");
  }
}
}