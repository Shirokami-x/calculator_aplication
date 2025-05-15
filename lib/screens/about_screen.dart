import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4, // Opsional: memberikan bayangan agar card terlihat lebih menonjol
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              "Terima kasih sudah coba Calculator! Aplikasi ini dibuat buat bantu kamu mempermudah dalam menghitung, dengan fitur menghitung perhitungan dasar,dan juga dapat menghitung bilangan yang kompleks. Semoga bermanfaat dan bisa bikin aktivitas kamu jadi lebih gampang! Kalau ada masukan, langsung aja kasih tahu ya!",
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}