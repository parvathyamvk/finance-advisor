import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddExpensePage extends StatefulWidget {
  final DateTime selectedDate;

  const AddExpensePage({
    super.key,
    required this.selectedDate,
  });

  @override
  State<AddExpensePage> createState() =>
      _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final FirestoreService fs = FirestoreService();
  late DateTime selectedDate;

@override
void initState() {
  super.initState();
  selectedDate = widget.selectedDate;

  getLocation(); // ✅ ADD THIS LINE
}

  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();
  String locationName = "Fetching...";

  String selectedCategory = "Food";

  final List<String> categories = [
    "Food",
    "Travel",
    "Shopping",
    "Snacks",
    "Bills",
    "Health",
    "Entertainment",
    "Others"
  ];

  Future<void> pickDate() async {
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
  }
  Future<void> getLocation() async {
  // Ask permission
  LocationPermission permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    setState(() {
      locationName = "Permission Denied";
    });
    return;
  }

  // Get coordinates
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // Convert to readable place
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

  if (placemarks.isNotEmpty) {
    setState(() {
      locationName =
          "${placemarks.first.locality}, ${placemarks.first.subLocality}";
    });
  }
}

  Future<void> saveExpense() async {
    final amount = double.tryParse(amountCtrl.text);
    // 🔹 Check average expense for this category
final snapshot = await fs.expenseStream(selectedDate).first;

double categoryTotal = 0;
int categoryCount = 0;

for (var doc in snapshot.docs) {
  final data = doc.data();

  if (data['category'] == selectedCategory) {
    categoryTotal += (data['amount'] ?? 0).toDouble();
    categoryCount++;
  }
}

double averageCategoryExpense = 0;

if (categoryCount > 0) {
  averageCategoryExpense = categoryTotal / categoryCount;
}
if (averageCategoryExpense > 0 &&
    amount! > averageCategoryExpense * 3) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "⚠ This expense is much higher than your usual spending in this category.",
      ),
    ),
  );
}

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    await fs.addExpense(
  amount: amount,
  category: selectedCategory,
  note: noteCtrl.text,
  date: selectedDate,
  location: locationName, // ✅ ADD THIS
);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: SizedBox(
            width: 450,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "New Expense",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                /// Amount
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                /// Category
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                /// Note
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: "Note",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

Text(
  "📍 Location: $locationName",
  style: const TextStyle(
    fontWeight: FontWeight.bold,
  ),
),

                const SizedBox(height: 20),

                /// Date Picker
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                      ),
                    ),
                    TextButton(
                      onPressed: pickDate,
                      child: const Text("Select Date"),
                    )
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveExpense,
                    child: const Text("Save Expense"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}