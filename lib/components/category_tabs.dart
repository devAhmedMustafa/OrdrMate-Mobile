import 'package:flutter/material.dart';
import '../models/Category.dart';
import '../ui/theme/app_theme.dart';

class CategoryTabs extends StatelessWidget {
  final List<Category> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        children: [
          _buildCategoryChip('All'),
          ...categories.map((category) => _buildCategoryChip(category.name)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = category == selectedCategory;
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingS),
      child: ChoiceChip(
        label: Text(
          category,
          style: TextStyle(
            color: isSelected ? AppTheme.surfaceColor : AppTheme.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) => onCategorySelected(category),
        backgroundColor: AppTheme.surfaceColor,
        selectedColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
      ),
    );
  }
} 