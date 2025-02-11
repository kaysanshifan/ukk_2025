import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class User {
  String id;
  String username;
  String password;
  String role;

  User({required this.id, required this.username, required this.password, required this.role});
}

class RolePage extends StatefulWidget {
  @override
  _RolePageState createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  List<User> userList = [];

  Future<void> fetchUsers() async {
    try {
      final response = await Supabase.instance.client.from('users').select();
      setState(() {
        userList = (response as List<dynamic>).map((item) {
          return User(
            id: item['id'],
            username: item['username'],
            password: item['password'],
            role: item['role'],
          );
        }).toList();
      });
    } catch (error) {
      print("Error fetching users: $error");
    }
  }

  Future<void> addUser(User user) async {
    try {
      await Supabase.instance.client.from('users').insert({
        'username': user.username,
        'password': user.password,
        'role': user.role,
      });
      fetchUsers();
    } catch (error) {
      print("Error adding user: $error");
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await Supabase.instance.client.from('users').update({
        'username': user.username,
        'password': user.password,
        'role': user.role,
      }).eq('id', user.id);
      fetchUsers();
    } catch (error) {
      print("Error updating user: $error");
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await Supabase.instance.client.from('users').delete().eq('id', id);
      fetchUsers();
    } catch (error) {
      print("Error deleting user: $error");
    }
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
        title: Text('Manage Users'),
      ),
      body: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) {
          final user = userList[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Text('Role: ${user.role}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Edit user
                    showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController usernameController = TextEditingController(text: user.username);
                        TextEditingController passwordController = TextEditingController(text: user.password);
                        TextEditingController roleController = TextEditingController(text: user.role);

                        return AlertDialog(
                          title: Text('Edit User'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: usernameController,
                                decoration: InputDecoration(labelText: 'Username'),
                              ),
                              TextField(
                                controller: passwordController,
                                decoration: InputDecoration(labelText: 'Password'),
                                obscureText: true,
                              ),
                              TextField(
                                controller: roleController,
                                decoration: InputDecoration(labelText: 'Role'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                updateUser(User(
                                  id: user.id,
                                  username: usernameController.text,
                                  password: passwordController.text,
                                  role: roleController.text,
                                ));
                                Navigator.pop(context);
                              },
                              child: Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteUser(user.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add user
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController usernameController = TextEditingController();
              TextEditingController passwordController = TextEditingController();
              TextEditingController roleController = TextEditingController();

              return AlertDialog(
                title: Text('Add User'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: roleController,
                      decoration: InputDecoration(labelText: 'Role'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      addUser(User(
                        id: '',
                        username: usernameController.text,
                        password: passwordController.text,
                        role: roleController.text,
                      ));
                      Navigator.pop(context);
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
