import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
static const String favoriteKey = 'favorite_meals';

// Mengambil semua favorite
Future<Set<String>> getFavorites() async {
final prefs = await SharedPreferences.getInstance();

final favorites = prefs.getStringList(favoriteKey) ?? [];

return favorites.toSet();

}

// Menambahkan dessert ke favorite
Future<void> addFavorite(String mealId) async {
final prefs = await SharedPreferences.getInstance();

final favorites = prefs.getStringList(favoriteKey) ?? [];

if (!favorites.contains(mealId)) {
  favorites.add(mealId);
}

await prefs.setStringList(
  favoriteKey,
  favorites,
);

}

// Menghapus dessert dari favorite
Future<void> removeFavorite(String mealId) async {
final prefs = await SharedPreferences.getInstance();

final favorites = prefs.getStringList(favoriteKey) ?? [];

favorites.remove(mealId);

await prefs.setStringList(
  favoriteKey,
  favorites,
);

}

// Mengecek apakah dessert sudah favorite
Future<bool> isFavorite(String mealId) async {
final favorites = await getFavorites();

return favorites.contains(mealId);

}
}
