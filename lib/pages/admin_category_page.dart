import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoryPage extends StatelessWidget {
  const AdminCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController categoryCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Category Management 🗂️")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// ADD CATEGORY
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: categoryCtrl,
                    decoration: const InputDecoration(
                      labelText: "New Category",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (categoryCtrl.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('categories')
                          .add({
                        'name': categoryCtrl.text.trim(),
                      });

                      categoryCtrl.clear();
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// CATEGORY LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final data = categories[index];

                      return Card(
                        child: ListTile(
                          title: Text(data['name']),

                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('categories')
                                  .doc(data.id)
                                  .delete();
                            },
                          ),
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
}