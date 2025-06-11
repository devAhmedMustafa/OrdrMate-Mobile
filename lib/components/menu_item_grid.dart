import 'package:flutter/material.dart';
import 'package:ordrmate/pages/item_page.dart';
import '../models/Item.dart';
import '../models/Restaurant.dart';
import '../models/Branch.dart';
import '../ui/theme/app_theme.dart';

class MenuItemGrid extends StatelessWidget {
  final List<Item> items;
  final Restaurant restaurant;
  final Branch selectedBranch;

  const MenuItemGrid({
    super.key,
    required this.items,
    required this.restaurant,
    required this.selectedBranch,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No items found in this category.',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 16,
          ),
        ),
      );
    }

    return GridView.builder(
      primary: false,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 0.65,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemPage(
                  item: item,
                  restaurant: restaurant,
                  selectedBranch: selectedBranch,
                ),
              ),
            );
          },
          child: Card(
            elevation: 0,
            color: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.borderRadiusM),
                    ),
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.backgroundColor,
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  size: 40,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppTheme.backgroundColor,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppTheme.backgroundColor,
                            child: Center(
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 50,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(AppTheme.borderRadiusM),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: AppTheme.textPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.description != null && item.description!.isNotEmpty) ...[
                              SizedBox(height: AppTheme.spacingXS),
                              Text(
                                item.description!,
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.price.toStringAsFixed(2)} EGP',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 