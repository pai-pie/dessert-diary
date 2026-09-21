class Meal {
  final String id;
  final String name;
  final String image;

  Meal({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Unknown Dessert',
      image: json['strMealThumb'] ?? '',
    );
  }
}