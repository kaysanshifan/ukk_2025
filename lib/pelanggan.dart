import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  List<dynamic> pelangganList = [];
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredList = [];

  Future<void> fetchPelanggan() async {
    final response = await Supabase.instance.client.from('pelanggan').select();
    setState(() {
      pelangganList = response;
      filteredList = pelangganList;
    });
  }

Future<bool> isPelangganExists(String nama) async {
  final response = await Supabase.instance.client
      .from('pelanggan')
      .select()
      .eq('nama', nama)
      .maybeSingle();
  return response != null;
}


  Future<void> addPelanggan() async {
    if (_namaController.text.isEmpty || _alamatController.text.isEmpty) return;

    bool exists = await isPelangganExists(_namaController.text);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pelanggan dengan nama yang sama sudah ada!'),
        ),
      );
      return;
    }

    await Supabase.instance.client.from('pelanggan').insert({
      'nama': _namaController.text,
      'alamat': _alamatController.text,
    });
    _namaController.clear();
    _alamatController.clear();
    fetchPelanggan();
  }

  Future<void> editPelanggan(int id, String nama, String alamat) async {
    _namaController.text = nama;
    _alamatController.text = alamat;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Pelanggan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(labelText: "Alamat"),
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
              await Supabase.instance.client.from('pelanggan').update({
                'nama': _namaController.text,
                'alamat': _alamatController.text,
              }).eq('id', id);
              fetchPelanggan();
              Navigator.pop(context);
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> deletePelanggan(int id) async {
    await Supabase.instance.client.from('pelanggan').delete().eq('id', id);
    fetchPelanggan();
  }

  void _filterPelanggan(String query) {
    setState(() {
      filteredList = pelangganList
          .where((pelanggan) =>
              pelanggan['nama'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pelanggan'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _namaController.clear();
              _alamatController.clear();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Tambah Pelanggan"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _namaController,
                        decoration: InputDecoration(labelText: "Nama"),
                      ),
                      TextField(
                        controller: _alamatController,
                        decoration: InputDecoration(labelText: "Alamat"),
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
                        await addPelanggan();
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
              controller: _searchController,
              onChanged: _filterPelanggan,
              decoration: InputDecoration(
                hintText: 'Cari pelanggan...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
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
                final pelanggan = filteredList[index];
                return ListTile(
                  title: Text(pelanggan['nama']),
                  subtitle: Text(pelanggan['alamat']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            editPelanggan(pelanggan['id'], pelanggan['nama'],
                                pelanggan['alamat']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Hapus Pelanggan"),
                            content: Text("Apakah Anda yakin ingin menghapus pelanggan ini?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () {
                                  deletePelanggan(pelanggan['id']);
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
