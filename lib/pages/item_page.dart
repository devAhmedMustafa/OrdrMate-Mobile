import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Item.dart';
import '../models/Restaurant.dart';
import '../models/RestaurantCart.dart';
import '../providers/cart_provider.dart';
import '../pages/cart_page.dart';
import '../models/Branch.dart';
import '../ui/theme/app_theme.dart';

class ItemPage extends StatefulWidget {
  final Item item;
  final Restaurant restaurant;
  final Branch selectedBranch;

  const ItemPage({
    super.key,
    required this.item,
    required this.restaurant,
    required this.selectedBranch,
  });

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  // Function to transform localhost URLs for emulator
  String? transformImageUrl(String? url) {
    if (url == null) return null;
    // Check if the URL contains localhost or 127.0.0.1
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      // Replace localhost/127.0.0.1 with 10.0.2.2 for emulator access
      return url.replaceFirst('localhost', '10.0.2.2').replaceFirst('127.0.0.1', '10.0.2.2');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    '${widget.item.price.toStringAsFixed(2)} EGP',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  if (widget.item.description != null && widget.item.description!.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      widget.item.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                  ],
                  const SizedBox(height: AppTheme.spacingS),
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
                      widget.item.category,
                      style: const TextStyle(
                        color: AppTheme.surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final restaurantCart = cart.getCartForRestaurant(widget.restaurant.id);
          final cartItem = restaurantCart?.items.firstWhere(
                (cartItem) => cartItem.item.id == widget.item.id,
            orElse: () => CartItem(item: widget.item, quantity: 0),
          );

          if (cartItem == null || cartItem.quantity == 0) {
            return Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: ElevatedButton(
                onPressed: () {
                  cart.addToCart(widget.item, widget.selectedBranch);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Item added to cart'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.surfaceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: AppTheme.shadowMedium,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (cartItem.quantity > 1) {
                            cart.updateItemQuantity(widget.item.id, widget.selectedBranch, cartItem.quantity - 1);
                          } else {
                            cart.removeFromCart(widget.item.id, widget.selectedBranch);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        '${cartItem.quantity}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      IconButton(
                        onPressed: () {
                          cart.updateItemQuantity(widget.item.id, widget.selectedBranch, cartItem.quantity + 1);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(
                          restaurantId: widget.restaurant.id,
                          selectedBranch: widget.selectedBranch,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.surfaceColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty
                ? Image.network(
                    transformImageUrl(widget.item.imageUrl)!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.backgroundColor,
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: AppTheme.textSecondaryColor,
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppTheme.backgroundColor,
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 80,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        color: AppTheme.surfaceColor,
      ),
    );
  }
}