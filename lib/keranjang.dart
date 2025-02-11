import 'package:flutter/material.dart';
import 'transaksi.dart';
import 'barang.dart';

class KeranjangPage extends StatelessWidget {
  final List<Barang> keranjang;

  KeranjangPage({required this.keranjang});

  @override
  Widget build(BuildContext context) {
    double totalHarga = keranjang.fold(0, (sum, item) => sum + item.harga * item.jumlah);

    return Scaffold(
      appBar: AppBar(title: Text('Keranjang')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: keranjang.length,
              itemBuilder: (context, index) {
                final barang = keranjang[index];
                return ListTile(
                  title: Text(barang.nama),
                  subtitle: Text("Jumlah: ${barang.jumlah} - Harga: Rp ${(barang.harga * barang.jumlah).toStringAsFixed(2)}"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Total Harga: Rp ${totalHarga.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransaksiBaruPage(keranjang: keranjang)),
          );
        },
        label: Text('Lanjut ke Pembayaran'),
        icon: Icon(Icons.payment),
      ),
    );
  }
}

