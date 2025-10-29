import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'history_page.dart'; // We will create this soon

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';

  // Get a reference to the Firestore collection
  final CollectionReference _history =
  FirebaseFirestore.instance.collection('calculations');

  // --- 1. Calculator Logic ---

  void _onButtonPressed(String buttonText) {
    setState(() {
      // ... (C and ⌫ logic remains the same)

      // Check for the equals button
      if (buttonText == '=') {
        // 1. Pre-check for empty expression
        if (_expression.isEmpty) {
          _result = '0';
          return; // Stop if nothing is entered
        }

        // 2. Prevent double operators or invalid trailing symbols
        String finalExpression = _expression.replaceAll('x', '*'); // Use '*' internally


        // Basic validation for trailing characters
        if (finalExpression.isNotEmpty) {
          RegExp trailingOperator = RegExp(r'[+\-*/.]$');

          if (trailingOperator.hasMatch(finalExpression)) {
            _result = 'Invalid Format';
            return;
          }
        }

        try {
          // Use the math_expressions package
          Parser p = Parser();
          Expression exp = p.parse(finalExpression); // Use the internally prepared expression
          ContextModel cm = ContextModel();

          // Ensure division by zero is handled before evaluation
          if (finalExpression.contains('/0')) {
            _result = 'Cannot Divide by Zero';
            // Do NOT save error to history
            return;
          }

          double eval = exp.evaluate(EvaluationType.REAL, cm);

          // Check for NaN or Infinity (common math errors)
          if (eval.isNaN || eval.isInfinite) {
            _result = 'Math Error';
            return;
          }

          // Format the result
          _result = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 4);

          // *** FIREBASE PART (Only save if successful) ***
          _saveCalculation(_expression, _result);

          _expression = _result;

        } catch (e) {
          // Catch parsing errors (e.g., "1++2" or "sin(5)" if not supported)
          _result = 'Error (Syntax)';
        }
      }
      // ... (Other buttons logic remains the same)
      else {
        // Prevent duplicate operators next to each other
        if (RegExp(r'[+\-*/]').hasMatch(buttonText) && RegExp(r'[+\-*/]').hasMatch(_expression.substring(_expression.length > 0 ? _expression.length - 1 : 0))) {
          return; // Ignore the button press
        }
        _expression += buttonText;
      }
    });
  }

  // --- 2. Save to Firebase Function ---

  Future<void> _saveCalculation(String expression, String result) async {
    try {
      await _history.add({
        'expression': expression,
        'result': result,
        'timestamp': FieldValue.serverTimestamp(), // Use server time for consistency
      });
      print("Calculation saved successfully!");
    } catch (e) {
      print("Error saving calculation: $e");
    }
  }

  // --- 3. Build the UI ---

  Widget _buildButton(String buttonText) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(24.0),
            backgroundColor: Colors.blueGrey[700],
            textStyle: TextStyle(fontSize: 24),
          ),
          onPressed: () => _onButtonPressed(buttonText),
          child: Text(buttonText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutterbase Calculator'),
        actions: [
          // Button to open history page
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // --- Display Screen ---
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(fontSize: 32, color: Colors.white70),
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    _result,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // --- Button Pad ---
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Row(children: [
                    _buildButton('7'), _buildButton('8'), _buildButton('9'), _buildButton('/'),
                  ]),
                ),
                Expanded(
                  child: Row(children: [
                    _buildButton('4'), _buildButton('5'), _buildButton('6'), _buildButton('*'),
                  ]),
                ),
                Expanded(
                  child: Row(children: [
                    _buildButton('1'), _buildButton('2'), _buildButton('3'), _buildButton('-'),
                  ]),
                ),
                Expanded(
                  child: Row(children: [
                    _buildButton('.'), _buildButton('0'), _buildButton('C'), _buildButton('+'),
                  ]),
                ),
                Expanded(
                  child: Row(children: [
                    _buildButton('⌫'), _buildButton('='),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}