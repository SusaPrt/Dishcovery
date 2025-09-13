import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/ingredient.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  void _changeEmail() async {
    final emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change email'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'New email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              if (newEmail.isNotEmpty && newEmail.contains('@')) {
                var sessionBox = await Hive.openBox('session');
                var email = sessionBox.get('currentUserEmail');
                var userBox = await Hive.openBox<User>('users');
                var currentUser = userBox.values.firstWhere(
                  (u) => u.email == email,
                  orElse: () => User(email: '', password: ''),
                );
                if (currentUser.email.isNotEmpty) {
                  currentUser.email = newEmail;
                  await currentUser.save();
                  sessionBox.put('currentUserEmail', newEmail);
                  var pantryBox = await Hive.openBox<Ingredient>('ingredients');
                  var cartBox = await Hive.openBox<Ingredient>('cart');
                  for (var ing in pantryBox.values.where((i) => i.ownerEmail == email)) {
                    ing.ownerEmail = newEmail;
                    await ing.save();
                  }
                  for (var ing in cartBox.values.where((i) => i.ownerEmail == email)) {
                    ing.ownerEmail = newEmail;
                    await ing.save();
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email updated!')),
                  );
                }
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Enter a valid email')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changePassword() async {
    final passwordController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change password'),
        content: TextField(
          controller: passwordController,
          decoration: InputDecoration(labelText: 'New password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPassword = passwordController.text.trim();
              if (newPassword.length >= 6) {
                var sessionBox = await Hive.openBox('session');
                var email = sessionBox.get('currentUserEmail');
                var userBox = await Hive.openBox<User>('users');
                var currentUser = userBox.values.firstWhere(
                  (u) => u.email == email,
                  orElse: () => User(email: '', password: ''),
                );
                if (currentUser.email.isNotEmpty) {
                  currentUser.password = newPassword;
                  await currentUser.save();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password updated!')),
                  );
                }
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password must be at least 6 characters long')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() async {
    final confirmController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete account'),
        content: Text('Type "DELETE" to confirm'),
        actions: [
          TextField(
            controller: confirmController,
            decoration: InputDecoration(labelText: 'Confirm'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (confirmController.text.trim().toUpperCase() == 'DELETE') {
                var sessionBox = await Hive.openBox('session');
                var email = sessionBox.get('currentUserEmail');
                var userBox = await Hive.openBox<User>('users');
                final toDelete = userBox.values.firstWhere(
                  (u) => u.email == email,
                  orElse: () => User(email: '', password: ''),
                );
                var pantryBox = await Hive.openBox<Ingredient>('ingredients');
                var cartBox = await Hive.openBox<Ingredient>('cart');
                pantryBox.values.where((i) => i.name == email).forEach((i) async => await i.delete());
                cartBox.values.where((i) => i.name == email).forEach((i) async => await i.delete());
                if (toDelete.email.isNotEmpty) {
                  await toDelete.delete();
                  await sessionBox.delete('currentUserEmail');
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Account deleted!')),
                  );
                }
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('img/logo.png', height: 32, width: 32),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFF8E1),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Color(0xFFFFF8E1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 32),
              SizedBox(
                width: 250,
                child: Card(
                  color: Colors.green[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.logout, color: Colors.black),
                    label: Text('Logout', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[300]),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 250,
                child: Card(
                  color: Colors.green[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.email, color: Colors.black),
                    label: Text('Change email', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[300]),
                    onPressed: _changeEmail,
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 250,
                child: Card(
                  color: Colors.green[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.lock, color: Colors.black),
                    label: Text('Change password', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[300]),
                    onPressed: _changePassword,
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 250,
                child: Card(
                  color: Colors.green[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.delete, color: Colors.black),
                    label: Text('Delete account', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _deleteAccount,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
