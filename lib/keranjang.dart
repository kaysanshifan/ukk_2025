import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'barang.dart';
import 'riwayat.dart'; // Update with your actual import path

class KeranjangPage extends StatefulWidget {
  final List<Barang> keranjang;

  KeranjangPage({required this.keranjang});

  @override
  _KeranjangPageState createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  double get totalHarga => widget.keranjang.fold(0, (sum, item) => sum + item.harga * item.jumlah);

  Future<void> savePenjualan() async {
    try {
      final response = await Supabase.instance.client.from('penjualan').insert({
        'tanggal_penjualan': DateTime.now().toIso8601String(),
        'total_harga': totalHarga,
        'username': 'USERNAME_HERE', // Replace with the actual username of the customer
      });
      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Penjualan berhasil disimpan')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RiwayatPage()), // Ensure RiwayatPage() is defined and imported
        );
      } else {
        throw response.error!;
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan penjualan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaksi')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.keranjang.length,
              itemBuilder: (context, index) {
                final barang = widget.keranjang[index];
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
        onPressed: savePenjualan,
        label: Text("Bayar"),
        icon: Icon(Icons.credit_card),
      ),
    );
  }
}
