import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Calculator'),
        ),
        body: CalculatorScreen(
          onNewHistoryEntry: (entry) {
            // Logika untuk meng-update riwayat kalkulasi jika diperlukan.
            debugPrint(entry);
          },
        ),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final Function(String) onNewHistoryEntry;

  const CalculatorScreen({Key? key, required this.onNewHistoryEntry})
      : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _controller = TextEditingController(text: "0");

  void _evaluateExpression() {
    String input = _controller.text;
    String expression = input.replaceAll("x", "*").replaceAll(" ", "");

    if (!RegExp(r'^[0-9\.\+\-\*\/]+$').hasMatch(expression)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Input tidak valid. Masukkan hanya angka dan operator."),
          duration: Duration(seconds: 2),
        ),
      );
      _controller.clear();
      return;
    }

    try {
      double result = _calculate(expression);
      String resultText =
          result % 1 == 0 ? result.toInt().toString() : result.toString();
      // Update riwayat kalkulasi melalui callback.
      widget.onNewHistoryEntry("$input = $resultText");
      _controller.text = resultText;
    } catch (e) {
      if (e.toString().contains("Division by zero")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pembagian dengan 0 tidak diizinkan!"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ekspresi tidak valid!"),
            duration: Duration(seconds: 2),
          ),
        );
      }
      _controller.clear();
    }
  }

  double _calculate(String expression) {
    List<String> tokens = [];
    String numberBuffer = "";
    for (int i = 0; i < expression.length; i++) {
      String ch = expression[i];
      if (_isDigit(ch) || ch == ".") {
        numberBuffer += ch;
      } else if (_isOperator(ch)) {
        if (numberBuffer.isNotEmpty) {
          tokens.add(numberBuffer);
          numberBuffer = "";
        }
        tokens.add(ch);
      }
    }
    if (numberBuffer.isNotEmpty) {
      tokens.add(numberBuffer);
    }

    List<String> outputQueue = [];
    List<String> operatorStack = [];
    Map<String, int> precedence = {
      "+": 1,
      "-": 1,
      "*": 2,
      "/": 2,
    };

    for (String token in tokens) {
      if (_isOperator(token)) {
        while (operatorStack.isNotEmpty &&
            precedence[operatorStack.last]! >= precedence[token]!) {
          outputQueue.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      } else {
        outputQueue.add(token);
      }
    }
    while (operatorStack.isNotEmpty) {
      outputQueue.add(operatorStack.removeLast());
    }

    List<double> evalStack = [];
    for (String token in outputQueue) {
      if (_isOperator(token)) {
        if (evalStack.length < 2) {
          throw Exception("Invalid expression");
        }
        double b = evalStack.removeLast();
        double a = evalStack.removeLast();
        double res = 0;
        switch (token) {
          case "+":
            res = a + b;
            break;
          case "-":
            res = a - b;
            break;
          case "*":
            res = a * b;
            break;
          case "/":
            if (b == 0) throw Exception("Division by zero");
            res = a / b;
            break;
        }
        evalStack.add(res);
      } else {
        evalStack.add(double.parse(token));
      }
    }
    if (evalStack.length != 1) {
      throw Exception("Invalid expression");
    }
    return evalStack.first;
  }

  bool _isDigit(String ch) {
    return "0123456789".contains(ch);
  }

  bool _isOperator(String ch) {
    return ch == "+" || ch == "-" || ch == "*" || ch == "/" || ch == "x";
  }

  // Fungsi baru untuk menghapus karakter terakhir (backspace)
  void _backspace() {
    String currentText = _controller.text;
    if (currentText.isNotEmpty && currentText != "0") {
      _controller.text = currentText.substring(0, currentText.length - 1);
      if (_controller.text.isEmpty) {
        _controller.text = "0";
      }
    }
  }

  void _buttonPressed(String buttonText) {
    String currentText = _controller.text;
    setState(() {
      if (buttonText == "C") { // Tombol clear diubah menjadi "C"
        _controller.text = "0";
      } else if (buttonText == "⌫") { // Penanganan tombol backspace
        _backspace();
      } else if (buttonText == "=") {
        _evaluateExpression();
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "x" ||
          buttonText == "/") {
        if (currentText == "0" || currentText.isEmpty) return;
        if (currentText.endsWith("+") ||
            currentText.endsWith("-") ||
            currentText.endsWith("x") ||
            currentText.endsWith("/")) {
          _controller.text =
              currentText.substring(0, currentText.length - 1) + buttonText;
        } else {
          _controller.text += buttonText;
        }
      } else {
        if (currentText == "0" && buttonText != ".") {
          _controller.text = buttonText;
        } else {
          List<String> parts = currentText.split(RegExp(r'[\+\-\*x\/]'));
          String currentNumber = parts.last;
          if (buttonText == "." && currentNumber.contains(".")) return;
          _controller.text += buttonText;
        }
      }
    });
  }

  // Semua tombol memiliki ukuran yang sama (80) sekarang.
  Widget _buildButton(String buttonText, {Color? color}) {
    double buttonWidth = 80;
    return SizedBox(
      width: buttonWidth,
      height: 80,
      child: Container(
        margin: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            backgroundColor: color ?? Colors.blueGrey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double horizontalPadding = constraints.maxWidth < 600 ? 12.0 : 0.0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: <Widget>[
                  // TextField untuk memasukkan ekspresi.
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(fontSize: 32.0),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Masukkan angka",
                      ),
                      keyboardType: TextInputType.text,
                      onSubmitted: (value) => _evaluateExpression(),
                    ),
                  ),
                  // Grid tombol kalkulator.
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildButton("7"),
                            _buildButton("8"),
                            _buildButton("9"),
                            _buildButton("/", color: Colors.orangeAccent),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildButton("4"),
                            _buildButton("5"),
                            _buildButton("6"),
                            _buildButton("x", color: Colors.orangeAccent),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildButton("1"),
                            _buildButton("2"),
                            _buildButton("3"),
                            _buildButton("-", color: Colors.orangeAccent),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildButton("."),
                            _buildButton("0"),
                            _buildButton("00"),
                            _buildButton("+", color: Colors.orangeAccent),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildButton("⌫", color: Colors.orangeAccent),
                            _buildButton("C", color: Colors.redAccent),
                            _buildButton("=", color: Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
