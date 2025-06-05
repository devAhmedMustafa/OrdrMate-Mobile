import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'checkout_page.dart';
import '../models/CartItem.dart';
import '../models/Branch.dart';
import '../ui/components/app_button.dart';
import '../ui/components/app_card.dart';
import '../ui/theme/app_theme.dart';

class CartPage extends StatelessWidget {
  final String restaurantId;
  final Branch selectedBranch;

  const CartPage({
    super.key,
    required this.restaurantId,
    required this.selectedBranch,
  });

  // Function to transform localhost URLs for emulator
  String? transformImageUrl(String? url) {
    if (url == null) return null;
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      return url.replaceFirst('localhost', '10.0.2.2').replaceFirst('127.0.0.1', '10.0.2.2');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Consumer<CartProvider>(
          builder: (context, cart, child) {
            final restaurantCart = cart.getCartForRestaurant(restaurantId);
            return Text(
              restaurantCart != null
                  ? '${restaurantCart.restaurantName} Cart'
                  : 'Cart',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            );
          },
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimaryColor),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final restaurantCart = cart.getCartForRestaurant(restaurantId);

          if (restaurantCart == null || restaurantCart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
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

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  itemCount: restaurantCart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = restaurantCart.items[index];
                    return AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        child: Row(
                          children: [
                            // Item Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                                color: AppTheme.backgroundColor,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                                child: cartItem.item.imageUrl != null && cartItem.item.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        transformImageUrl(cartItem.item.imageUrl)!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.restaurant,
                                              size: 40,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.restaurant,
                                          size: 40,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItem.item.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingXS),
                                  Text(
                                    '${cartItem.item.price.toStringAsFixed(2)} EGP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (cartItem.quantity > 1) {
                                      cart.updateItemQuantity(
                                        cartItem.item.id,
                                        selectedBranch,
                                        cartItem.quantity - 1,
                                      );
                                    } else {
                                      cart.removeFromCart(
                                        cartItem.item.id,
                                        selectedBranch,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppTheme.textSecondaryColor,
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    cart.updateItemQuantity(
                                      cartItem.item.id,
                                      selectedBranch,
                                      cartItem.quantity + 1,
                                    );
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  boxShadow: AppTheme.shadowMedium,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        Text(
                          '${restaurantCart.totalPrice.toStringAsFixed(2)} EGP',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    AppButton(
                      text: 'Proceed to Checkout',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              items: restaurantCart.items.map(
                                (item) => CartItem(
                                  id: item.item.id,
                                  name: item.item.name,
                                  price: item.item.price,
                                  quantity: item.quantity,
                                ),
                              ).toList(),
                              selectedBranch: selectedBranch,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}