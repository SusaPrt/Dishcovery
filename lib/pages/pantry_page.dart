import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ingredient.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  Box<Ingredient>? ingredientBox;
  Box? userBox;
  String currentUserEmail = '';
  bool isBoxReady = false;

  @override
  void initState() {
    super.initState();
    _openBoxes();
  }

  Future<void> _openBoxes() async {
    ingredientBox = await Hive.openBox<Ingredient>('ingredients');
    // userBox = await Hive.openBox('users'); // non serve più
    var sessionBox = await Hive.openBox('session');
    final email = sessionBox.get('currentUserEmail');
    setState(() {
      currentUserEmail = email is String ? email : '';
      isBoxReady = true;
    });
  }

  void _addIngredient() async {
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity = int.tryParse(quantityController.text) ?? 0;
              final exists = ingredientBox?.values.any((i) =>
                i.ownerEmail == currentUserEmail && i.name.toLowerCase() == name.toLowerCase()) ?? false;
              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ingredient already exists in pantry')),
                );
                return;
              }
              if (name.isNotEmpty && quantity > 0) {
                ingredientBox?.add(Ingredient(
                  name: name,
                  quantity: quantity,
                  unit: selectedUnit,
                  ownerEmail: currentUserEmail,
                ));
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter valid name and quantity')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editIngredient(int index, Ingredient ingredient) async {
    final nameController = TextEditingController(text: ingredient.name);
    final quantityController = TextEditingController(text: ingredient.quantity.toString());
    String selectedUnit = ingredient.unit;
    final units = ['gr', 'kg', 'ml', 'l', 'pz'];
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Ingredient'),
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (name.isNotEmpty && quantity > 0) {
                ingredient.name = name;
                ingredient.quantity = quantity;
                ingredient.unit = selectedUnit;
                ingredient.save();
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeIngredient(int index) {
    ingredientBox?.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('img/logo.png', height: 48, width: 48),
        ),
        title: Text('Pantry', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFFFF8E1),
        iconTheme: IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Color(0xFFFFF8E1),
        child: !isBoxReady || ingredientBox == null
            ? Center(child: CircularProgressIndicator())
            : ValueListenableBuilder(
                valueListenable: ingredientBox!.listenable(),
                builder: (context, Box<Ingredient> box, _) {
                  final userIngredients = box.values
                      .where((i) => i.ownerEmail == currentUserEmail)
                      .toList();
                  if (userIngredients.isEmpty) {
                    return Center(child: Text('No ingredients added.', style: TextStyle(color: Colors.black)));
                  }
                  return ListView.builder(
                    itemCount: userIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = userIngredients[index];
                      final boxIndex = box.values.toList().indexOf(ingredient);
                      return Center(
                        child: SizedBox(
                          width: 350,
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            color: Colors.green[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            child: ListTile(
                              title: Text(
                                ingredient.name,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Quantity: ${ingredient.quantity} ${ingredient.unit}',
                                style: TextStyle(color: Colors.black),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.black),
                                    onPressed: () {
                                      _editIngredient(boxIndex, ingredient);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _removeIngredient(boxIndex);
                                    },
                                  ),
                                ],
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
        onPressed: _addIngredient,
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}
