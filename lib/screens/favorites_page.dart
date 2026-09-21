import 'package:flutter/material.dart';
import '../services/meal_service.dart';
import '../services/favorite_service.dart';
import 'detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final MealService mealService = MealService();
  final FavoriteService favoriteService = FavoriteService();

  Set<String> favoriteIds = {};
  List<Map<String, dynamic>> favoriteMeals = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // =========================
  // LOAD FAVORITES
  // =========================
  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    final ids = await favoriteService.getFavorites();
    final List<Map<String, dynamic>> meals = [];

    for (final id in ids) {
      try {
        final meal = await mealService.getMealDetail(id);
        meals.add(meal);
      } catch (e) {
        // Lewati dessert jika gagal mengambil data
      }
    }

    if (!mounted) return;

    setState(() {
      favoriteIds = ids;
      favoriteMeals = meals;
      isLoading = false;
    });
  }

  // =========================
  // REMOVE FAVORITE
  // =========================
  Future<void> removeFavorite(String mealId) async {
    await favoriteService.removeFavorite(mealId);

    if (!mounted) return;

    setState(() {
      favoriteIds.remove(mealId);
      favoriteMeals.removeWhere((meal) => meal['idMeal'] == mealId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F5),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F5),
        elevation: 0,
        title: const Text(
          'My Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5A3E42),
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadFavorites,
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFFE8A0A8),
            ),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE8A0A8),
              ),
            )
          : favoriteMeals.isEmpty
              ? _buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: favoriteMeals.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final meal = favoriteMeals[index];
                      final String mealId = meal['idMeal'] ?? '';
                      final String mealName =
                          meal['strMeal'] ?? 'Unknown Dessert';
                      final String mealImage = meal['strMealThumb'] ?? '';

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(mealId: mealId),
                            ),
                          );

                          // Refresh setelah kembali
                          loadFavorites();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // =========================
                              // CARD CONTENT
                              // =========================
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // IMAGE
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child: Image.network(
                                      mealImage,
                                      height: 145,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 145,
                                          color: const Color(0xFFF7E6E8),
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported_outlined,
                                              size: 35,
                                              color: Color(0xFFE8A0A8),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // NAME
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(11, 10, 11, 4),
                                    child: Text(
                                      mealName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5A3E42),
                                      ),
                                    ),
                                  ),

                                  // VIEW RECIPE
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 11),
                                    child: Row(
                                      children: [
                                        Text(
                                          'View recipe',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFE19AA2),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 10,
                                          color: Color(0xFFE19AA2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // =========================
                              // REMOVE FAVORITE BUTTON
                              // =========================
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    removeFavorite(mealId);
                                  },
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 23,
                                      color: Color(0xFFE8A0A8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFF7E6E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 45,
                color: Color(0xFFE8A0A8),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A3E42),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save your favorite desserts\nand find them here ♡',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF8A6A6E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}