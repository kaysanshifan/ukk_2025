import 'package:flutter/material.dart';

class StokBarang extends StatelessWidget {
  final VoidCallback onDataChanged;

  StokBarang({required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Barang'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Panggil onDataChanged ketika data diubah
            onDataChanged();
            Navigator.pop(context);
          },
          child: Text('Perbarui Stok'),
        ),
      ),
    );
  }
}
