import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  void _changeEmail() async {
    final emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambia email'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Nuova email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
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
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email aggiornata!')),
                  );
                }
              }
            },
            child: Text('Salva'),
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
        title: Text('Cambia password'),
        content: TextField(
          controller: passwordController,
          decoration: InputDecoration(labelText: 'Nuova password'),
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
                    SnackBar(content: Text('Password aggiornata!')),
                  );
                }
              }
            },
            child: Text('Salva'),
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
        title: Text('Elimina account'),
        content: Text('Scrivi "ELIMINA" per confermare'),
        actions: [
          TextField(
            controller: confirmController,
            decoration: InputDecoration(labelText: 'Conferma'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (confirmController.text.trim().toUpperCase() == 'ELIMINA') {
                var sessionBox = await Hive.openBox('session');
                var email = sessionBox.get('currentUserEmail');
                var userBox = await Hive.openBox<User>('users');
                final toDelete = userBox.values.firstWhere(
                  (u) => u.email == email,
                  orElse: () => User(email: '', password: ''),
                );
                if (toDelete.email.isNotEmpty) {
                  await toDelete.delete();
                  await sessionBox.delete('currentUserEmail');
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Account eliminato!')),
                  );
                }
              }
            },
            child: Text('Elimina'),
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
