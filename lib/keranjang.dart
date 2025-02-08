import 'package:flutter/material.dart';
import 'barang.dart'; // Import kelas Barang

class KeranjangPage extends StatefulWidget {
  final List<Barang> keranjang;

  KeranjangPage({required this.keranjang});

  @override
  _KeranjangPageState createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  void removeFromKeranjang(int index) {
    setState(() {
      widget.keranjang.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalHarga = widget.keranjang.fold(0, (sum, item) => sum + item.harga);

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.keranjang.length,
              itemBuilder: (context, index) {
                final barang = widget.keranjang[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(barang.nama),
                    subtitle: Text("Rp ${barang.harga.toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        removeFromKeranjang(index);
                      },
                    ),
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
          // Implementasi checkout
        },
        label: Text('Checkout'),
        icon: Icon(Icons.shopping_cart_checkout),
      ),
    );
  }
}
