class Character {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> comics;
  final List<String> series;
  final List<String> stories;

  const Character({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.comics,
    required this.series,
    required this.stories,
  });
}
