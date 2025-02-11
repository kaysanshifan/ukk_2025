import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'keranjang.dart';
import 'barang.dart';
import 'stok_barang.dart';
import 'pelanggan.dart'; // Import halaman daftar pelanggan

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
            stok: item['stok'] ?? 0, // Tambahkan stok di sini
            id: item['id'] ?? 0,
            jumlah: 0, // Tambahkan jumlah dengan nilai awal 0
          );
        }).toList();
      });
    } catch (error) {
      print("Error fetching barang: $error");
    }
  }

  void addToKeranjang(Barang barang, int jumlah) {
    setState(() {
      var existingBarang = keranjang.firstWhere(
          (item) => item.id == barang.id,
          orElse: () => Barang(nama: '', harga: 0.0, stok: 0, id: 0, jumlah: 0));
      if (existingBarang.id != 0) {
        existingBarang.jumlah += jumlah;
      } else {
        keranjang.add(Barang(
          nama: barang.nama,
          harga: barang.harga,
          stok: barang.stok,
          id: barang.id,
          jumlah: jumlah,
        ));
      }
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
      backgroundColor: Color(0xffffffff),
      body: _selectedIndex == 0 || _selectedIndex == 1
          ? Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pattern.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  CustomSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        query = value;
                      });
                    },
                  ),
                  Expanded(child: _selectedIndex == 0 ? buildBarangList() : StokBarang(onDataChanged: updateBarangList)),
                ],
              ),
            )
          : _selectedIndex == 2
              ? PelangganPage() // Tambahkan halaman daftar pelanggan
              : KeranjangPage(keranjang: keranjang),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xffff5722),
        unselectedItemColor: Color(0xff212121),
        backgroundColor: Color(0xffffffff),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: "Halaman utama",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "List barang",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Daftar Pelanggan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Keranjang",
          ),
        ],
      ),
    );
  }

  Widget buildBarangList() {
    return ListView.builder(
      itemCount: barangList.length,
      itemBuilder: (context, index) {
        final barang = barangList[index];
        if (query.isEmpty ||
            barang.nama.toLowerCase().contains(query.toLowerCase())) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(barang.nama),
              subtitle: Text("Rp ${barang.harga.toStringAsFixed(2)} - Stok: ${barang.stok}"), // Tambahkan stok di sini
              trailing: IconButton(
                icon: Icon(Icons.add_shopping_cart_rounded),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      TextEditingController _jumlahController = TextEditingController();
                      return AlertDialog(
                        title: Text("Tambahkan ke Keranjang"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Stok tersedia: ${barang.stok}"),
                            TextField(
                              controller: _jumlahController,
                              decoration: InputDecoration(labelText: "Jumlah"),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () {
                              int jumlah = int.parse(_jumlahController.text);
                              if (jumlah > 0 && jumlah <= barang.stok) {
                                addToKeranjang(barang, jumlah);
                                Navigator.pop(context);
                              } else {
                                // Tampilkan pesan error jika jumlah tidak valid
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Jumlah tidak valid"),
                                ));
                              }
                            },
                            child: Text("Tambah"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  CustomSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari barang...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 0.0),
        ),
      ),
    );
  }
}
