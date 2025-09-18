import '../../domain/domain.dart';

class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.comics,
    required super.series,
    required super.stories,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'] as Map<String, dynamic>?;
    final imageUrl = thumbnail != null
        ? '${thumbnail['path']}.${thumbnail['extension']}'
        : '';

    final comics = json['comics']?['items'] as List<dynamic>? ?? [];
    final series = json['series']?['items'] as List<dynamic>? ?? [];
    final stories = json['stories']?['items'] as List<dynamic>? ?? [];

    return CharacterModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: imageUrl,
      comics: comics.map((item) => item['name'] as String).toList(),
      series: series.map((item) => item['name'] as String).toList(),
      stories: stories.map((item) => item['name'] as String).toList(),
    );
  }
}
