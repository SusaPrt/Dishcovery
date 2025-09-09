import 'dart:convert';
import 'package:http/http.dart' as http;

class SpoonacularApi {
  static const String _apiKey = '';
  static const String _baseUrl = 'https://api.spoonacular.com/recipes/findByIngredients';

  static Future<List<dynamic>> searchRecipesByIngredients(List<String> ingredients, {int number = 15}) async {
    final String ingredientsParam = ingredients.join(',');
    final Uri url = Uri.parse('$_baseUrl?ingredients=$ingredientsParam&number=$number&ranking=2&ignorePantry=true&apiKey=$_apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> recipes = jsonDecode(response.body);
      // Filter recipes to have at most 2 missing ingredients
      return recipes.where((r) => (r['missedIngredientCount'] ?? 0) <= 2).toList();
    } else {
      throw Exception('Failed to load recipes: ${response.statusCode}');
    }
  }
}
