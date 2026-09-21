import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealService {
  static const String baseUrl =
      'https://www.themealdb.com/api/json/v1/1';

  // Mengambil semua dessert
  Future<List<Meal>> getDesserts() async {
    final url = Uri.parse('$baseUrl/filter.php?c=Dessert');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final meals = data['meals'] as List;

      return meals.map((meal) {
        return Meal.fromJson(meal);
      }).toList();
    } else {
      throw Exception('Failed to load desserts');
    }
  }

  // Mencari dessert berdasarkan nama
  Future<List<Meal>> searchDesserts(String query) async {
    final url = Uri.parse(
      '$baseUrl/search.php?s=${Uri.encodeComponent(query)}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Kalau tidak ada hasil pencarian
      if (data['meals'] == null) {
        return [];
      }

      final meals = data['meals'] as List;

      // Hanya mengambil dessert
      final desserts = meals.where((meal) {
        return meal['strCategory'] == 'Dessert';
      }).map((meal) {
        return Meal.fromJson(meal);
      }).toList();

      return desserts;
    } else {
      throw Exception('Failed to search desserts');
    }
  }

  // Mengambil detail recipe
  Future<Map<String, dynamic>> getMealDetail(String id) async {
    final url = Uri.parse('$baseUrl/lookup.php?i=$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['meals'][0];
    } else {
      throw Exception('Failed to load recipe detail');
    }
  }
}