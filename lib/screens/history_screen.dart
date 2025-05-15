import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<String> history;
  final VoidCallback? onClear; // Callback untuk mengosongkan history

  const HistoryScreen({
    Key? key,
    required this.history,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tombol "Clear History" hanya muncul jika history tidak kosong dan onClear tidak null.
        if (history.isNotEmpty && onClear != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear),
                label: const Text("Clear History"),
              ),
            ),
          ),
        Expanded(
          child: history.isEmpty
              ? const Center(child: Text("Belum ada riwayat perhitungan."))
              : ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(history[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
