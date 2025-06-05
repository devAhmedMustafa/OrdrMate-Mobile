import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'cart_page.dart';
import '../ui/theme/app_theme.dart';

class MainCartPage extends StatelessWidget {
  const MainCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimaryColor),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.carts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Add some items to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: cart.carts.length,
            itemBuilder: (context, index) {
              final restaurantCart = cart.carts.values.elementAt(index);
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                color: AppTheme.surfaceColor,
                child: InkWell(
                  onTap: restaurantCart.branchId != null && restaurantCart.branch != null
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(
                          restaurantId: restaurantCart.restaurantId,
                          selectedBranch: restaurantCart.branch,
                        ),
                      ),
                    );
                  }
                      : null,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurantCart.restaurantName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                                vertical: AppTheme.spacingS,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
                              ),
                              child: Text(
                                '${restaurantCart.totalItems} items',
                                style: const TextStyle(
                                  color: AppTheme.surfaceColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            Text(
                              '${restaurantCart.totalPrice.toStringAsFixed(2)} EGP',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}