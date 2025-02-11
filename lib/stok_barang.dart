import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StokBarang extends StatefulWidget {
  final Function onDataChanged;

  const StokBarang({Key? key, required this.onDataChanged}) : super(key: key);

  @override
  _StokBarangState createState() => _StokBarangState();
}

class _StokBarangState extends State<StokBarang> {
  List<dynamic> barangList = [];
  List<dynamic> filteredList = [];
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  Future<void> fetchBarang() async {
    final response = await Supabase.instance.client.from('products').select();
    setState(() {
      barangList = response;
      filteredList = barangList;
    });
  }

  Future<bool> isBarangExists(String nama) async {
  final response = await Supabase.instance.client
      .from('products')
      .select()
      .eq('nama', nama)
      .maybeSingle();
  return response != null;
}

  Future<void> addBarang() async {
    if (_namaController.text.isEmpty || _hargaController.text.isEmpty || _stokController.text.isEmpty) return;

    bool exists = await isBarangExists(_namaController.text);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barang dengan nama yang sama sudah ada!'),
        ),
      );
      return;
    }

    await Supabase.instance.client.from('products').insert({
      'nama': _namaController.text,
      'harga': double.parse(_hargaController.text),
      'stok': int.parse(_stokController.text),
    });
    _namaController.clear();
    _hargaController.clear();
    _stokController.clear();
    fetchBarang();
    widget.onDataChanged();
  }

  Future<void> editBarang(int id, String nama, double harga, int stok) async {
    _namaController.text = nama;
    _hargaController.text = harga.toString();
    _stokController.text = stok.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Barang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: "Nama Barang"),
            ),
            TextField(
              controller: _hargaController,
              decoration: InputDecoration(labelText: "Harga"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _stokController,
              decoration: InputDecoration(labelText: "Stok"),
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
            onPressed: () async {
              await Supabase.instance.client.from('products').update({
                'nama': _namaController.text,
                'harga': double.parse(_hargaController.text),
                'stok': int.parse(_stokController.text),
              }).eq('id', id);
              fetchBarang(); // Memastikan data terbaru diambil
              Navigator.pop(context);
              widget.onDataChanged();
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteBarang(int id) async {
    await Supabase.instance.client.from('products').delete().eq('id', id);
    fetchBarang(); // Memastikan data terbaru diambil
    widget.onDataChanged();
  }

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  void _filterBarang(String query) {
    setState(() {
      filteredList = barangList
          .where((barang) => barang['nama'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Barang'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _namaController.clear();
              _hargaController.clear();
              _stokController.clear();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Tambah Barang"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _namaController,
                        decoration: InputDecoration(labelText: "Nama Barang"),
                      ),
                      TextField(
                        controller: _hargaController,
                        decoration: InputDecoration(labelText: "Harga"),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _stokController,
                        decoration: InputDecoration(labelText: "Stok"),
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
                      onPressed: () async {
                        await addBarang();
                        Navigator.pop(context);
                      },
                      child: Text("Simpan"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterBarang,
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final barang = filteredList[index];
                return ListTile(
                  title: Text(barang['nama']),
                  subtitle: Text(
                    "Rp ${barang['harga'].toStringAsFixed(2)} - Stok: ${barang['stok']}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => editBarang(
                          barang['id'],
                          barang['nama'],
                          barang['harga'],
                          barang['stok'],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Hapus Barang"),
                            content: Text("Apakah Anda yakin ingin menghapus barang ini?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteBarang(barang['id']);
                                  Navigator.pop(context);
                                },
                                child: Text("Hapus"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );  
              },
            ),
          ),
        ],
      ),
    );
  }
}
