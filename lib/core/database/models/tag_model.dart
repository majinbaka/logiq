import 'db_types.dart';

class TagModel {
  const TagModel({
    required this.id,
    required this.tagType,
    required this.name,
    this.description,
    this.colorKey,
    required this.isSystem,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tagType;
  final String name;
  final String? description;
  final String? colorKey;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory TagModel.fromMap(DbJson map) => TagModel(
    id: map['id'] as String,
    tagType: map['tag_type'] as String,
    name: map['name'] as String,
    description: parseString(map['description']),
    colorKey: parseString(map['color_key']),
    isSystem: parseBool(map['is_system']) ?? false,
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
  );

  DbJson toMap() => {
    'id': id,
    'tag_type': tagType,
    'name': name,
    'description': description,
    'color_key': colorKey,
    'is_system': isSystem,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
