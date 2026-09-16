import 'package:mind_whispers_app/features/reader/domain/entities/category.dart';

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
   
      color: json['color'] as String? ?? '#A78BFA',
    );
  }

  Category toEntity() => Category(id: id, name: name, slug: slug, color: color);
}
