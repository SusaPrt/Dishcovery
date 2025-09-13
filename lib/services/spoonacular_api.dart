import 'dart:convert';
import 'package:http/http.dart' as http;

class SpoonacularApi {
  static const String _apiKey = '560c22b688324468a76bd7211f1a8b44';
  static const String _baseUrl = 'https://api.spoonacular.com/recipes/findByIngredients';

  static Future<List<dynamic>> searchRecipesByIngredients(List<String> ingredients, {int number = 20}) async {
    final String ingredientsParam = ingredients.join(',');
    final Uri url = Uri.parse('$_baseUrl?ingredients=$ingredientsParam&number=$number&ranking=2&ignorePantry=true&apiKey=$_apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> recipes = jsonDecode(response.body);
      return recipes.where((r) => (r['missedIngredientCount'] ?? 0) <= 3).toList();
    } else {
      throw Exception('Failed to load recipes: ${response.statusCode}');
    }
  }
}
