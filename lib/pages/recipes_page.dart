import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ingredient.dart';
import '../services/spoonacular_api.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<dynamic>? recipes;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final box = await Hive.openBox<Ingredient>('ingredients');
      final ingredients = box.values.map((i) => i.name).toList();
      if (ingredients.isEmpty) {
        setState(() {
          recipes = [];
          isLoading = false;
        });
        return;
      }
      final result = await SpoonacularApi.searchRecipesByIngredients(ingredients);
      setState(() {
        recipes = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('img/logo.png', height: 48, width: 48),
        ),
        title: const Text('Recipes', style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFF8E1),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
  color: Color(0xFFFFF8E1),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text('Error:\n$error', style: TextStyle(color: Colors.black)))
                : (recipes == null || recipes!.isEmpty)
                    ? Center(child: Text('No recipes found for your pantry ingredients.', style: TextStyle(color: Colors.black)))
                    : ListView.builder(
                        itemCount: recipes!.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes![index];
                          final missedIngredients = recipe['missedIngredients'] as List<dynamic>?;
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: Colors.green[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe['title'] ?? 'No title',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Using: ${recipe['usedIngredients'] != null && (recipe['usedIngredients'] as List).isNotEmpty
                                        ? (recipe['usedIngredients'] as List).map((ing) => ing['name']).join(', ')
                                        : 'None'}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  if (missedIngredients != null && missedIngredients.isNotEmpty) ...[
                                    SizedBox(height: 8),
                                    Text('Missing ingredients:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                    ...missedIngredients.map((ing) => Row(
                                      children: [
                                        Expanded(
                                          child: Text('- ${ing['name']} (${ing['original']})', style: TextStyle(color: Colors.black)),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add_shopping_cart, color: Colors.black),
                                          tooltip: 'Add to cart',
                                          onPressed: () async {
                                            String name = ing['name'] ?? '';
                                            String original = ing['original'] ?? '';
                                            int quantity = 1;
                                            String unit = '';
                                            final match = RegExp(r'([0-9]+)\s*([a-zA-Z]*)').firstMatch(original);
                                            if (match != null) {
                                              quantity = int.tryParse(match.group(1) ?? '1') ?? 1;
                                              unit = match.group(2) ?? '';
                                            }
                                            var cartBox = await Hive.openBox<Ingredient>('cart');
                                            var sessionBox = await Hive.openBox('session');
                                            final email = sessionBox.get('currentUserEmail');
                                            await cartBox.add(Ingredient(name: name, quantity: quantity, unit: unit, ownerEmail: email));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Added $name to cart')),
                                            );
                                          },
                                        ),
                                      ],
                                    )),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}