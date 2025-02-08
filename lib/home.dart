import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transaksi.dart';
import 'keranjang.dart'; // Import halaman Keranjang
import 'barang.dart'; // Import kelas Barang
import 'stok_barang.dart'; // Import kelas StokBarang

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Barang> barangList = [];
  List<Barang> keranjang = [];
  TextEditingController _searchController = TextEditingController();
  String query = "";

  Future<void> fetchBarang() async {
    try {
      final response = await Supabase.instance.client.from('products').select();
      setState(() {
        barangList = (response as List<dynamic>).map((item) {
          return Barang(
            nama: item['nama'] ?? '',
            harga: (item['harga'] as num?)?.toDouble() ?? 0.0,
            id: item['id'] ?? 0,
          );
        }).toList();
      });
    } catch (error) {
      print("Error fetching barang: $error");
    }
  }

  // Menambahkan barang ke keranjang
  void addToKeranjang(Barang barang) {
    setState(() {
      keranjang.add(barang);
    });
  }

  void updateBarangList() {
    fetchBarang();
  }

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/meat.jpg'),
        ),
      ),
      body: _selectedIndex == 0
          ? Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pattern.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: buildBarangList(),
            )
          : _selectedIndex == 1
              ? StokBarang(onDataChanged: updateBarangList) // Panggil callback di sini
              : _selectedIndex == 2
                  ? TransaksiBaruPage(keranjang: keranjang)
                  : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.app_shortcut), label: "Menu Produk"),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_rounded), label: "List Produk"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: "Transaksi"),
        ],
      ),
      // Floating Action Button for Keranjang
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 60.0), // Adjusted to not overlap with BottomNav
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KeranjangPage(keranjang: keranjang),
              ),
            );
          },
          child: Icon(Icons.shopping_cart),
        ),
      ),
    );
  }

  Widget buildBarangList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search items...",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: barangList.length,
            itemBuilder: (context, index) {
              final barang = barangList[index];
              if (query.isEmpty ||
                  barang.nama.toLowerCase().contains(query.toLowerCase())) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(barang.nama),
                    subtitle: Text("Rp ${barang.harga.toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: () {
                        addToKeranjang(barang); // Menambahkan ke keranjang
                      },
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }
}
