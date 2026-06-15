import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double monthlyCap;

  /// Phase 9. When true, this category's monthly *total* is visible to the
  /// linked partner — never the individual transactions. Opt-in, defaults
  /// to false (incl. for categories created after linking).
  final bool sharedWithPartner;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.monthlyCap,
    this.sharedWithPartner = false,
  });

  Category copyWith({
    String? name,
    IconData? icon,
    Color? color,
    double? monthlyCap,
    bool? sharedWithPartner,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      monthlyCap: monthlyCap ?? this.monthlyCap,
      sharedWithPartner: sharedWithPartner ?? this.sharedWithPartner,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'color': color.toARGB32(),
    'monthlyCap': monthlyCap,
    'sharedWithPartner': sharedWithPartner,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: IconData(
      json['icon'] as int,
      fontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
    ),
    color: Color(json['color'] as int),
    monthlyCap: (json['monthlyCap'] as num).toDouble(),
    sharedWithPartner: json['sharedWithPartner'] as bool? ?? false,
  );
}
