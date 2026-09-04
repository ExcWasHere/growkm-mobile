import 'package:flutter/material.dart';

class ProductTourStep {
  final String title;
  final String description;
  final IconData icon;
  final GlobalKey? targetKey;

  const ProductTourStep({
    required this.title,
    required this.description,
    required this.icon,
    this.targetKey,
  });
}