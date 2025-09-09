import 'package:flutter/material.dart';
import 'pantry_page.dart';
import 'recipes_page.dart';
import 'settings_page.dart';
import 'cart_page.dart';

class MainAppPage extends StatefulWidget {
  const MainAppPage({super.key});

  @override
  _MainAppPageState createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    PantryPage(),
    RecipesPage(),
    CartPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.kitchen, color: Colors.black),
              label: 'Pantry',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long, color: Colors.black),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, color: Colors.black),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
        ),
      ),
    );
  }
}
