import 'package:flutter/material.dart';
import '../models/Restaurant.dart';
import '../ui/theme/app_theme.dart';

class RestaurantHeader extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantHeader({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    const int rating = 4;

    return Container(
      child: Stack(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.primaryColor,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.surfaceColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                const SizedBox(height: AppTheme.spacingS),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: AppTheme.secondaryColor,
                        size: 20,
                      );
                    })
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 