import 'package:flutter/material.dart';  // this is improved counter app
import 'package:provider/provider.dart'; // Make sure this import is present

// Your CounterModel class (from Step 2 - assuming it's in this file)
class CounterModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterModel(), // Create an instance of your CounterModel
      child: const MyApp(), // Your existing MyApp widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // Or your app's title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Optional, but good practice for new apps
      ),
      home: const MyHomePage(title: 'Flutter Counter with Provider'), // Your existing MyHomePage
    );
  }
}

// ... rest of your code for MyHomePage etc. (which we will modify in Step 4) ...

// Example: Your existing MyHomePage and _MyHomePageState (before Step 4 modifications)
// You might still have something like this:
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    // Access the CounterModel.
    // Use `listen: false` if you are only calling methods from callbacks
    // and using Consumer/Selector for UI updates.
    final counterModel = Provider.of<CounterModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add some overall padding
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround, // Distributes space
          children: <Widget>[
            // Left side: Counter Display
            Expanded(
              flex: 2, // Give more space to the counter display
              child: Center(
                // Use Consumer to listen to changes in CounterModel and rebuild only this Text
                child: Consumer<CounterModel>(
                  builder: (context, model, child) {
                    return Text(
                      'Count: ${model.count}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 36, // Adjusted font size
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 20), // Spacer between counter and buttons

            // Right side: Buttons in a Column
            Expanded(
              flex: 1, // Give less space to the buttons column
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center buttons vertically
                crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch horizontally
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () => counterModel.increment(),
                    icon: const Icon(Icons.add),
                    label: const Text('Increment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12), // Spacing between buttons
                  ElevatedButton.icon(
                    onPressed: () => counterModel.decrement(),
                    icon: const Icon(Icons.remove),
                    label: const Text('Decrement'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12), // Spacing between buttons
                  ElevatedButton.icon(
                    onPressed: () => counterModel.reset(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}