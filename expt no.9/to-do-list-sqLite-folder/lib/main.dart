// main.dart - All-in-one Todosqlite App Implementation

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// --- 1. DATA MODEL (Todo) ---
// Defines the structure of a single task.
class Todo {
  final int? id;
  final String title;

  Todo({this.id, required this.title});

  // Convert a Todo into a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }

  // Helper for debugging.
  @override
  String toString() {
    return 'Todo{id: $id, title: $title}';
  }
}

// --- 2. DATABASE HELPER (DatabaseHelper) ---
// Manages all SQLite operations (CRUD).
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  final String tableName = 'todos';
  final String columnId = 'id';
  final String columnTitle = 'title';

  // Lazy load the database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database path and creation logic.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Executes the SQL to create the table.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT
      )
    ''');
  }

  // --- CRUD Operations ---

  // Insert a Todo into the database.
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert(
      tableName,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all Todos from the database.
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    // Convert the List<Map> into a List<Todo>.
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i][columnId],
        title: maps[i][columnTitle],
      );
    });
  }

  // Delete a Todo by its ID.
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}

// --- 3. FLUTTER APP ENTRY POINT ---
void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TodoSqlite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

// --- 4. UI (TodoListScreen) ---
// Stateful widget to handle the UI and database interaction logic.
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Todo>> _todoListFuture;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load tasks immediately when the screen starts
    _refreshTodoList();
  }

  // Refreshes the Future that fetches the list of todos.
  void _refreshTodoList() {
    setState(() {
      _todoListFuture = dbHelper.getTodos();
    });
  }

  // Handles adding a new task to the database.
  void _addTodo() async {
    if (_taskController.text.trim().isNotEmpty) {
      final newTodo = Todo(title: _taskController.text.trim());
      await dbHelper.insertTodo(newTodo);
      _taskController.clear();
      // Refresh the list to show the new item
      _refreshTodoList();
    }
  }

  // Handles deleting a task from the database.
  void _deleteTodo(int id) async {
    await dbHelper.deleteTodo(id);
    // Refresh the list to remove the deleted item
    _refreshTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoSqlite Tasks'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Todo>>(
        future: _todoListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading tasks: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('🎉 No tasks yet! Add your first one below.'));
          } else {
            // Display the list of tasks from SQLite
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final todo = snapshot.data![index];
                return ListTile(
                  title: Text(todo.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteTodo(todo.id!), // Call delete function
                  ),
                );
              },
            );
          }
        },
      ),
      // Input area for new tasks at the bottom
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    labelText: 'Enter New Task',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              FloatingActionButton.small(
                onPressed: _addTodo,
                tooltip: 'Add Task',
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}