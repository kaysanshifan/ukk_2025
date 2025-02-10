import 'package:flutter/material.dart';
import 'barang.dart';

class TransaksiBaruPage extends StatelessWidget {
  final List<Barang> keranjang;

  TransaksiBaruPage({required this.keranjang});

  @override
  Widget build(BuildContext context) {
    double totalHarga = keranjang.fold(0, (sum, item) => sum + item.harga);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi Baru'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: keranjang.length,
              itemBuilder: (context, index) {
                final barang = keranjang[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(barang.nama),
                    subtitle: Text("Rp ${barang.harga.toStringAsFixed(2)}"),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total Harga: Rp ${totalHarga.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implementasi transaksi
        },
        label: Text('Bayar'),
        icon: Icon(Icons.payment),
      ),
    );
  }
}
