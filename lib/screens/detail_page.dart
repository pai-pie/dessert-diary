import 'package:flutter/material.dart';
import '../services/meal_service.dart';

class DetailPage extends StatefulWidget {
  final String mealId;

  const DetailPage({
    super.key,
    required this.mealId,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final MealService mealService = MealService();

  late Future<Map<String, dynamic>> mealDetail;

  @override
  void initState() {
    super.initState();
    mealDetail = mealService.getMealDetail(widget.mealId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F5),
      body: FutureBuilder<Map<String, dynamic>>(
        future: mealDetail,
        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE8A0A8),
              ),
            );
          }

          // ERROR
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
                    'Oops! Recipe could not be loaded.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A3E42),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final meal = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // HEADER IMAGE
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFFE8A0A8),
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    meal['strMealThumb'],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF7E6E8),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 50,
                          color: Color(0xFFE8A0A8),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // CONTENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // RECIPE NAME
                      Text(
                        meal['strMeal'] ?? 'Unknown Dessert',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A3E42),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // CATEGORY + AREA
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.category_outlined,
                            text: meal['strCategory'] ??
                                'Dessert',
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.public,
                            text:
                                meal['strArea'] ?? 'Unknown',
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // INGREDIENTS
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A3E42),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildIngredients(meal),

                      const SizedBox(height: 30),

                      // INSTRUCTIONS
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A3E42),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: Text(
                          meal['strInstructions'] ??
                              'No instructions available.',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFF6F5A5D),
                          ),
                        ),
                      ),

                      // SOURCE
                      if (meal['strSource'] != null &&
                          meal['strSource']
                              .toString()
                              .trim()
                              .isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const Text(
                          'Recipe Source',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A3E42),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meal['strSource'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8A6A6E),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIngredients(
      Map<String, dynamic> meal) {
    final List<Map<String, String>> ingredients = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient =
          meal['strIngredient$i'];
      final measure =
          meal['strMeasure$i'];

      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty) {
        ingredients.add({
          'ingredient': ingredient.toString().trim(),
          'measure': measure?.toString().trim() ?? '',
        });
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: ingredients.map((item) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(
                    top: 6,
                    right: 10,
                  ),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8A0A8),
                  ),
                ),
                Expanded(
                  child: Text(
                    item['ingredient']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5A3E42),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  item['measure']!,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A6A6E),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E6E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFFE19AA2),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8A6A6E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}