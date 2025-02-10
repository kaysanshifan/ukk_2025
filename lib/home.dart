  import 'package:flutter/material.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'keranjang.dart'; 
  import 'barang.dart'; 
  import 'stok_barang.dart'; 

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
        backgroundColor: Color(0xffffffff),
        body: _selectedIndex == 0
            ? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/pattern.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    SearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          query = value;
                        });
                      },
                    ),
                    Expanded(child: buildBarangList()),
                  ],
                ),
              )
            : _selectedIndex == 1
                ? Column(
                    children: [
                      SearchBar(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            query = value;
                          });
                        },
                      ),
                      Expanded(
                        child: StokBarang(onDataChanged: updateBarangList),
                      ),
                    ],
                  )
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
                subtitle: Text("Rp ${barang.harga.toStringAsFixed(2)}"),
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart_rounded),
                  onPressed: () {
                    addToKeranjang(barang);
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
