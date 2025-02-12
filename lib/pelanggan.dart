import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  List<dynamic> userList = [];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredList = [];

  Future<void> fetchUsers() async {
    final response = await Supabase.instance.client
        .from('user')
        .select('id, username, alamat')
        .eq('role', 'pelanggan');

    setState(() {
      userList = response.map((user) {
        return {
          'id': user['id'] ?? 0,
          'username': user['username'] ?? '',
          'alamat': user['alamat'] ?? '',
        };
      }).toList();
      filteredList = userList;
    });
  }

  Future<bool> isUserExists(String username) async {
    final response = await Supabase.instance.client
        .from('user')
        .select()
        .eq('username', username)
        .maybeSingle();
    return response != null;
  }

  Future<void> addUser() async {
    if (_usernameController.text.isEmpty || _alamatController.text.isEmpty) return;
  
    bool exists = await isUserExists(_usernameController.text);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengguna dengan username yang sama sudah ada!'),
        ),
      );
      return;
    }

    await Supabase.instance.client.from('user').insert({
      'username': _usernameController.text,
      'alamat': _alamatController.text,
      'role': 'pelanggan',
    });
    _usernameController.clear();
    _alamatController.clear();
    fetchUsers();
  }

  Future<void> editUser(int id, String username, String alamat) async {
    _usernameController.text = username;
    _alamatController.text = alamat;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Pengguna"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
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
              await Supabase.instance.client.from('user').update({
                'username': _usernameController.text,
                'alamat': _alamatController.text,
              }).eq('id', id);
              fetchUsers();
              Navigator.pop(context);
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUser(int id) async {
    await Supabase.instance.client.from('user').delete().eq('id', id);
    fetchUsers();
  }

  void _filterUsers(String query) {
    setState(() {
      filteredList = userList
          .where((user) =>
              user['username'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengguna'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _usernameController.clear();
              _alamatController.clear();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Tambah Pengguna"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: "Username"),
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
                        await addUser();
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
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
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
                final user = filteredList[index];
                return ListTile(
                  title: Text(user['username']),
                  subtitle: Text(user['alamat']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => editUser(user['id'], user['username'],
                            user['alamat']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Hapus Pengguna"),
                            content: Text("Apakah Anda yakin ingin menghapus pengguna ini?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteUser(user['id']);
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
