import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ingredient.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Box<Ingredient>? cartBox;
  String currentUserEmail = '';
  bool isBoxReady = false;

  @override
  void initState() {
    super.initState();
    _openCartBox();
  }

  Future<void> _openCartBox() async {
    cartBox = await Hive.openBox<Ingredient>('cart');
    var sessionBox = await Hive.openBox('session');
    final email = sessionBox.get('currentUserEmail');
    setState(() {
      currentUserEmail = email is String ? email : '';
      isBoxReady = true;
    });
  }

  void _addCartItemManually() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    String selectedUnit = 'gr';
    final units = ['gr', 'kg', 'ml', 'l', 'pz'];
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedUnit,
              items: units.map((unit) => DropdownMenuItem(
                value: unit,
                child: Text(unit),
              )).toList(),
              onChanged: (value) {
                if (value != null) selectedUnit = value;
              },
              decoration: InputDecoration(labelText: 'Unit'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity = int.tryParse(quantityController.text) ?? 0;
              final exists = cartBox?.values.any((i) =>
                i.ownerEmail == currentUserEmail && i.name.toLowerCase() == name.toLowerCase()) ?? false;
              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ingredient already exists in cart')),
                );
                return;
              }
              if (name.isNotEmpty) {
                cartBox?.add(Ingredient(
                  name: name,
                  quantity: quantity,
                  unit: selectedUnit,
                  ownerEmail: currentUserEmail,
                ));
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeCartItem(int index) {
    cartBox?.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('img/logo.png', height: 32, width: 32),
        ),
        title: Text('Shopping Cart', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFFFF8E1),
        iconTheme: IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Color(0xFFFFF8E1),
        child: !isBoxReady
            ? Center(child: CircularProgressIndicator())
            : ValueListenableBuilder(
                valueListenable: cartBox!.listenable(),
                builder: (context, Box<Ingredient> box, _) {
                  // Filter cart items for current user
                  final userCartItems = box.values
                      .where((i) => i.ownerEmail == currentUserEmail)
                      .toList();
                  if (userCartItems.isEmpty) {
                    return Center(child: Text('Your cart is empty.', style: TextStyle(color: Colors.black)));
                  }
                  return ListView.builder(
                    itemCount: userCartItems.length,
                    itemBuilder: (context, index) {
                      final item = userCartItems[index];
                      // Find the actual index in the box for delete
                      final boxIndex = box.values.toList().indexOf(item);
                      return Center(
                        child: SizedBox(
                          width: 350,
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            color: Colors.green[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            child: ListTile(
                              title: Text(item.name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              subtitle: Text('Quantity: ${item.quantity} ${item.unit}', style: TextStyle(color: Colors.black)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeCartItem(boxIndex),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCartItemManually,
        backgroundColor: Colors.green,
        tooltip: 'Add item manually',
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}