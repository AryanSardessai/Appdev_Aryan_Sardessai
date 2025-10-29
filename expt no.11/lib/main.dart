import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
// We need to import the http package for network requests
import 'package:http/http.dart' as http;

// The API endpoint we are using
const String _apiUrl = 'https://yoga-api-nzy4.onrender.com/v1/poses';

// --- 1. YOGA POSE MODEL (MODEL) ---
/// Represents a single yoga pose entry.
/// Updated to match the expected structure of the external API response.
class YogaPose {
  final int id;
  // The API uses 'sanskrit_name' and 'english_name' (snake_case)
  final String sanskritName;
  final String englishName;
  // The API uses 'pose_description'
  final String description;

  YogaPose({
    required this.id,
    required this.sanskritName,
    required this.englishName,
    required this.description,
  });

  /// Factory constructor to create a YogaPose instance from a Map.
  factory YogaPose.fromMap(Map<String, dynamic> map) {
    return YogaPose(
      // The API returns 'id' as an integer
      id: map['id'] as int,
      // Mapping snake_case API keys to camelCase Dart properties
      sanskritName: map['sanskrit_name'] as String,
      englishName: map['english_name'] as String,
      description: map['pose_description'] as String,
    );
  }
}

// --- 2. API SERVICE (USING REAL EXTERNAL API) ---
/// Handles fetching a list of yoga poses from the external REST API.
class ApiService {

  /// Fetches the list of yoga poses from the external API.
  Future<List<YogaPose>> fetchPoses() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Decode the JSON array from the response body
        final List<dynamic> jsonList = json.decode(response.body);

        // Convert the list of JSON objects into a list of YogaPose objects
        return jsonList.map((json) => YogaPose.fromMap(json)).toList();
      } else {
        // Throw an exception for non-200 status codes
        throw Exception('Failed to load poses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any network or decoding errors
      // Use the generic 'Exception' class to ensure it's displayed nicely in the UI
      throw Exception('Network Error: Could not connect to $_apiUrl. Error: $e');
    }
  }
}

// --- 3. MAIN APPLICATION (VIEW/CONTROLLER) ---

void main() {
  runApp(const YogaPoseApp());
}

class YogaPoseApp extends StatelessWidget {
  const YogaPoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoga Pose List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          color: Colors.green,
          foregroundColor: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const YogaPoseListScreen(),
    );
  }
}

class YogaPoseListScreen extends StatefulWidget {
  const YogaPoseListScreen({super.key});

  @override
  State<YogaPoseListScreen> createState() => _YogaPoseListScreenState();
}

class _YogaPoseListScreenState extends State<YogaPoseListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<YogaPose>> _futurePoses;

  @override
  void initState() {
    super.initState();
    // Start fetching data immediately
    _futurePoses = apiService.fetchPoses();
  }

  /// Function to re-fetch data.
  Future<void> _refreshData() async {
    setState(() {
      _futurePoses = apiService.fetchPoses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoga Pose Catalog (API)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Poses from API',
          ),
        ],
      ),
      body: FutureBuilder<List<YogaPose>>(
        future: _futurePoses,
        builder: (context, snapshot) {
          // --- LOADING STATE ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('Fetching live pose data...', style: TextStyle(color: Colors.green)),
                ],
              ),
            );
          }

          // --- ERROR STATE ---
          if (snapshot.hasError) {
            // Display the error message in the UI
            final errorText = snapshot.error.toString().replaceFirst('Exception: ', '');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.redAccent, size: 60),
                    const SizedBox(height: 16),
                    Text('API Connection Error', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.redAccent)),
                    const SizedBox(height: 8),
                    Text(errorText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Refreshing'),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<YogaPose> poses = snapshot.data!;

          // --- EMPTY STATE ---
          if (poses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  Text('No Poses Found', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('The API returned an empty list of poses.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                ],
              ),
            );
          }

          // --- SUCCESS STATE (List View) ---
          return RefreshIndicator(
            onRefresh: _refreshData,
            color: Colors.green,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: poses.length,
              itemBuilder: (context, index) {
                final pose = poses[index];
                return _buildPoseTile(context, pose);
              },
            ),
          );
        },
      ),
    );
  }

  // Widget to build an individual pose list tile
  Widget _buildPoseTile(BuildContext context, YogaPose pose) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          foregroundColor: Colors.green.shade800,
          child: Text(pose.id.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(
          pose.sanskritName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.green,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              pose.englishName,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pose.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: () => _showPoseDetails(context, pose),
      ),
    );
  }

  // Helper function to show pose details in a dialog
  void _showPoseDetails(BuildContext context, YogaPose pose) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(pose.sanskritName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(pose.englishName, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                const Divider(),
                const Text('Full Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(pose.description, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
