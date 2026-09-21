import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import '../services/favorite_service.dart';
import 'detail_page.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({
    super.key,
    required this.username,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MealService mealService = MealService();
  final FavoriteService favoriteService = FavoriteService();

  final TextEditingController searchController = TextEditingController();

  late Future<List<Meal>> desserts;

  Set<String> favoriteIds = {};

  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    desserts = mealService.getDesserts();

    loadFavorites();

    searchController.addListener(() {
      setState(() {});
    });
  }

  // =========================
  // LOAD FAVORITES
  // =========================
  Future<void> loadFavorites() async {
    final favorites = await favoriteService.getFavorites();

    if (!mounted) return;

    setState(() {
      favoriteIds = favorites;
    });
  }

  // =========================
  // TOGGLE FAVORITE
  // =========================
  Future<void> toggleFavorite(String mealId) async {
    if (favoriteIds.contains(mealId)) {
      await favoriteService.removeFavorite(mealId);

      if (!mounted) return;

      setState(() {
        favoriteIds.remove(mealId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      await favoriteService.addFavorite(mealId);

      if (!mounted) return;

      setState(() {
        favoriteIds.add(mealId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to favorites ♡'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // =========================
  // SEARCH
  // =========================
  void searchDesserts() {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        desserts = mealService.getDesserts();
      });
      return;
    }

    setState(() {
      isSearching = true;
      desserts = mealService.searchDesserts(query);
    });
  }

  // =========================
  // CLEAR SEARCH
  // =========================
  void clearSearch() {
    searchController.clear();

    setState(() {
      isSearching = false;
      desserts = mealService.getDesserts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================
  // OPEN FAVORITES PAGE
  // =========================
  Future<void> openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritesPage(),
      ),
    );

    loadFavorites();
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
          'Dessert Diary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5A3E42),
          ),
        ),
        actions: [
          IconButton(
            onPressed: openFavorites,
            icon: const Icon(
              Icons.favorite_border,
              color: Color(0xFFE8A0A8),
              size: 27,
            ),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // =========================
            // GREETING
            // =========================
            Text(
              'Hello, ${widget.username}! ♡',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A3E42),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'What sweet treat do you want today?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A6A6E),
              ),
            ),
            const SizedBox(height: 20),

            // =========================
            // SEARCH BAR
            // =========================
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  searchDesserts();
                },
                decoration: InputDecoration(
                  hintText: 'Search desserts...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB9A4A7),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFE8A0A8),
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: clearSearch,
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFFB9A4A7),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 26),

            // =========================
            // TITLE
            // =========================
            Text(
              isSearching ? 'Search Results' : 'Popular Desserts',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A3E42),
              ),
            ),
            const SizedBox(height: 12),

            // =========================
            // DESSERT LIST
            // =========================
            Expanded(
              child: FutureBuilder<List<Meal>>(
                future: desserts,
                builder: (context, snapshot) {
                  // =========================
                  // LOADING
                  // =========================
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE8A0A8),
                      ),
                    );
                  }

                  // =========================
                  // ERROR
                  // =========================
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            size: 50,
                            color: Color(0xFFE8A0A8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Oops! Something went wrong.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A3E42),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A6A6E),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final meals = snapshot.data ?? [];

                  // =========================
                  // EMPTY
                  // =========================
                  if (meals.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 50,
                            color: Color(0xFFE8A0A8),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Dessert not found ♡',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A3E42),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // =========================
                  // GRID
                  // =========================
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: meals.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      final bool isFavorite = favoriteIds.contains(meal.id);

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(mealId: meal.id),
                            ),
                          );

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
                              // CARD
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
                                      meal.image,
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
                                      meal.name,
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
                              // FAVORITE BUTTON
                              // =========================
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    toggleFavorite(meal.id);
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
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 23,
                                      color: const Color(0xFFE8A0A8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}