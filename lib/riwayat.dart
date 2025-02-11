import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  final List<String> riwayatList = [
    'Riwayat 1',
    'Riwayat 2',
    'Riwayat 3',
    'Riwayat 4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality here
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: riwayatList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.history),
            title: Text(riwayatList[index]),
            onTap: () {
              // Handle item tap here
            },
          );
        },
      ),
    );
  }
}
