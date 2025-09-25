import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // A nice color for the AppBar
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Use TickerProviderStateMixin for TabController animation
class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Titles for our tabs and corresponding content
  final List<String> _tabTitles = ["Home", "Feed", "Profile"];
  final List<IconData> _tabIcons = [Icons.home, Icons.list_alt, Icons.person];

  @override
  void initState() {
    super.initState();
    // Initialize the TabController
    // length must match the number of tabs
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose(); // Important to dispose of the controller
    super.dispose();
  }

  // Helper function to create placeholder content for each tab/drawer item
  Widget _buildContent(String title, {Color color = Colors.grey}) {
    return Container(
      color: color.withOpacity(0.1), // Slight background color
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              // Simple icon logic based on title - you'd have specific icons
              title.contains("Home") ? Icons.home_filled :
              title.contains("Feed") ? Icons.dynamic_feed :
              title.contains("Profile") ? Icons.account_circle :
              title.contains("Settings") ? Icons.settings :
              Icons.info_outline,
              size: 80,
              color: color,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              "Content for the $title page",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Navigation'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        // The TabBar is placed in the bottom of the AppBar
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: List<Widget>.generate(_tabTitles.length, (index) {
            return Tab(
              icon: Icon(_tabIcons[index]),
              text: _tabTitles[index],
            );
          }),
        ),
      ),
      // Drawer: The navigation panel that slides in from the side
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Remove any padding from the ListView
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'User Name',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'user.name@example.com',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Go to Home Tab'),
              onTap: () {
                // Navigate to the first tab
                _tabController.animateTo(0);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('Go to Feed Tab'),
              onTap: () {
                // Navigate to the second tab
                _tabController.animateTo(1);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Go to Profile Tab'),
              onTap: () {
                // Navigate to the third tab
                _tabController.animateTo(2);
                Navigator.pop(context); // Close the drawer
              },
            ),
            const Divider(), // A visual separator
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                // Handle navigation for Settings (could be a new screen or another tab)
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings Tapped! (Implement Navigation)')),
                );
                // Example: If Settings were another screen:
                // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About'),
              onTap: () {
                // Handle navigation for About
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('About Tapped! (Implement Navigation)')),
                );
              },
            ),
          ],
        ),
      ),
      // TabBarView displays the content for the currently selected tab
      body: TabBarView(
        controller: _tabController,
        children: List<Widget>.generate(_tabTitles.length, (index) {
          // Use the helper to create distinct content for each tab
          Color contentColor = Colors.primaries[index % Colors.primaries.length].shade300;
          return _buildContent(_tabTitles[index], color: contentColor);
        }),
      ),
    );
  }
}

// Example of a SettingsScreen (if you were to navigate to a new page from the drawer)
// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: const Center(child: Text('Settings Page Content', style: TextStyle(fontSize: 24))),
//     );
//   }
// }

