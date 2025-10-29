import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  final CollectionReference _history =
  FirebaseFirestore.instance.collection('calculations');

  // New function to clear the history
  Future<void> _clearHistory(BuildContext context) async {
    // 1. Get all documents in the collection
    QuerySnapshot snapshot = await _history.get();

    // 2. Use a WriteBatch for efficient bulk deletion
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (DocumentSnapshot doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    // 3. Commit the batch
    await batch.commit();

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calculation history cleared!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculation History'),
        actions: [
          // Add the Clear History button
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () => _clearHistory(context), // Call the new function
          ),
        ],
      ),
      // ... (rest of the StreamBuilder logic remains the same)
      body: StreamBuilder<QuerySnapshot>(
        // ... (rest of the StreamBuilder logic)
        // (You can copy the existing StreamBuilder code here)
        stream: _history.orderBy('timestamp', descending: true).limit(50).snapshots(),
        builder: (context, snapshot) {
          // ... (existing code for loading, error, and display)
          // (You can copy the existing builder code here)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No history found.'));
          }

          final calculations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: calculations.length,
            itemBuilder: (context, index) {
              final data = calculations[index].data() as Map<String, dynamic>;
              final String expression = data['expression'] ?? '...';
              final String result = data['result'] ?? '...';
              final Timestamp? timestamp = data['timestamp'];
              final String time = timestamp != null
                  ? timestamp.toDate().toLocal().toString().split('.')[0]
                  : 'Just now';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    '$expression = $result',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(time),
                ),
              );
            },
          );
        },
      ),
    );
  }
}