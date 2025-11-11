import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/calculator.dart';

void main() {
  group('Calculator Tests', () {
    final calculator = Calculator();

    test('Addition test', () {
      expect(calculator.add(10, 5), 15);
    });

    test('Subtraction test', () {
      expect(calculator.subtract(10, 5), 5);
    });

    test('Multiplication test', () {
      expect(calculator.multiply(4, 3), 12);
    });

    test('Division test', () {
      expect(calculator.divide(10, 2), 5);
    });

    test('Division by zero throws an exception', () {
      expect(() => calculator.divide(10, 0), throwsException);
    });
  });
}
