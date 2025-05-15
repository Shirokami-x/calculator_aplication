import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<String> _history = [];

  // Callback untuk menambahkan entri baru ke riwayat.
  void _addHistory(String entry) {
    setState(() {
      _history.add(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan judul AppBar sesuai dengan tab yang aktif.
    String title;
    switch (_currentIndex) {
      case 0:
        title = "Kalkulator";
        break;
      case 1:
        title = "Riwayat";
        break;
      case 2:
        title = "Tentang Aplikasi";
        break;
      default:
        title = "Kalkulator";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Halaman kalkulator menerima callback _addHistory untuk menyimpan perhitungan.
          CalculatorScreen(onNewHistoryEntry: _addHistory),
          // Halaman riwayat menampilkan list perhitungan.
          HistoryScreen(history: _history),
          // Halaman tentang aplikasi.
          const AboutScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: "Kalkulator",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Riwayat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "Tentang",
          ),
        ],
      ),
    );
  }
}
