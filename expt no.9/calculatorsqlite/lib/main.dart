import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:math_expressions/math_expressions.dart';
void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Calculator',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey[800],
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';
  Database? _db;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    String path = join(await getDatabasesPath(), 'calc_history.db');
    _db = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE history(id INTEGER PRIMARY KEY, expression TEXT, result TEXT)',
        );
      },
      version: 1,
    );
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final List<Map<String, dynamic>> history = await _db!.query('history', orderBy: 'id DESC');
    setState(() {
      _history = history;
    });
  }

  Future<void> _saveToHistory(String expression, String result) async {
    await _db!.insert('history', {'expression': expression, 'result': result});
    _loadHistory();
  }

  void _onButtonPressed(String value) {
  setState(() {
    // Prevent consecutive operators (only allow a leading '-' to start an expression)
    const ops = ['+', '-', '*', '/', '×', '÷'];
    if (ops.contains(value)) {
      if (_expression.isEmpty) {
        // allow leading minus only
        if (value == '-') _expression = '-';
        return;
      }
      // if last char is operator, replace it with new operator
      final last = _expression[_expression.length - 1];
      if (ops.contains(last)) {
        // replace last operator (prevents ++, +-, *-, etc.)
        _expression = _expression.substring(0, _expression.length - 1) + value;
        return;
      }
    }

    if (value == 'C') {
      _expression = '';
      _result = '';
    } else if (value == '⌫') {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    } else if (value == '=') {
      _calculate();
    } else {
      // append digits, dot, or operator
      _expression += value;
    }
  });
}

void _calculate() {
  // Don't evaluate empty or trailing-operator expressions
  if (_expression.isEmpty) return;

  // remove trailing operator
  final lastChar = _expression[_expression.length - 1];
  if (['+', '-', '*', '/', '×', '÷'].contains(lastChar)) {
    // ignore evaluate if trailing operator
    setState(() {
      _result = 'Error';
    });
    return;
  }

  final eval = _evaluateExpression(_expression);
  setState(() {
    _result = eval;
  });

  if (eval != 'Error' && eval != 'Invalid') {
    _saveToHistory(_expression, eval);
  }
}

String _evaluateExpression(String expr) {
  try {
    // convert display operators to parser operators
    String sanitized = expr.replaceAll('×', '*').replaceAll('÷', '/');

    // Remove whitespace
    sanitized = sanitized.replaceAll(' ', '');

    // Prevent double operators (like '--' or '+*') — reduce them conservatively:
    // Replace sequences of operators with a single operator where appropriate
    sanitized = sanitized.replaceAllMapped(RegExp(r'([+\-*/]){2,}'), (m) {
      final seq = m.group(0)!;
      // if sequence contains '-' as last char keep '-' else keep last operator
      return seq.endsWith('-') ? '-' : seq[seq.length - 1];
    });

    // parse & evaluate using math_expressions
    Parser p = Parser();
    Expression exp = p.parse(sanitized);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);

    // Format: if integer, return without .0, else show up to 10 decimal trimmed
    if (eval == eval.roundToDouble()) {
      return eval.toInt().toString();
    } else {
      // trim trailing zeros
      String out = eval.toStringAsFixed(10);
      out = out.replaceFirst(RegExp(r'\.?0+$'), '');
      return out;
    }
  } catch (e) {
    return 'Error';
  }
}


  void _clearHistory() async {
    await _db!.delete('history');
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      '7', '8', '9', '/',
      '4', '5', '6', '*',
      '1', '2', '3', '-',
      'C', '0', '=', '+',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen(history: _history, clearHistory: _clearHistory)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: const TextStyle(fontSize: 32, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _result,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[900],
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final value = buttons[index];
                  final isOperator = ['/', '*', '-', '+', '='].contains(value);
                  return ElevatedButton(
                    onPressed: () => _onButtonPressed(value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOperator ? Colors.orange : Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                    ),
                    child: Center(
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 28, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final VoidCallback clearHistory;

  const HistoryScreen({required this.history, required this.clearHistory, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearHistory,
          )
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No history yet.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  leading: const Icon(Icons.calculate),
                  title: Text(item['expression']),
                  subtitle: Text('= ${item['result']}'),
                );
              },
            ),
    );
  }
}
