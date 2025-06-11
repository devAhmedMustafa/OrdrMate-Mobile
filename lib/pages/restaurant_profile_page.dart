import 'package:flutter/material.dart';
import 'package:ordrmate/pages/cart_page.dart';
import 'package:ordrmate/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../models/Restaurant.dart';
import '../models/Item.dart';
import '../models/Category.dart';
import '../models/Branch.dart';
import '../services/restaurant_service.dart';
import '../providers/cart_provider.dart';
import '../components/restaurant_header.dart';
import '../components/category_tabs.dart';
import '../components/menu_item_grid.dart';
import '../ui/components/app_button.dart';
import '../ui/theme/app_theme.dart';

class RestaurantProfilePage extends StatefulWidget {
  final String restaurantId;
  final String branchId;
  final Branch selectedBranch;

  const RestaurantProfilePage({
    super.key,
    required this.restaurantId,
    required this.branchId,
    required this.selectedBranch,
  });

  @override
  State<RestaurantProfilePage> createState() => _RestaurantProfilePageState();
}

class _RestaurantProfilePageState extends State<RestaurantProfilePage> {
  // Initialize the restaurant service
  Restaurant? _restaurant;
  List<Item> _items = [];
  List<Category> _categories = [];
  BranchInfo? _branchInfo;
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final RestaurantService restaurantService = RestaurantService(authService);

      final restaurant = await restaurantService.getRestaurantDetails(widget.restaurantId);
      final items = await restaurantService.getRestaurantItems(widget.selectedBranch.id);
      final categories = await restaurantService.getRestaurantCategories(widget.restaurantId);
      final branchInfo = await restaurantService.getBranchInfo(widget.branchId);

      if (!mounted) return;

      setState(() {
        _restaurant = restaurant;
        _items = items;
        _categories = categories;
        _branchInfo = branchInfo;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Item> _getFilteredItems() {
    if (_selectedCategory == 'All') {
      return _items;
    }
    return _items.where((item) => item.category == _selectedCategory).toList();
  }

  String _formatWaitingTime(double minutes) {
    final hours = (minutes / 60).floor();
    final mins = minutes.round() % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              final restaurantCart = cart.getCartForRestaurant(widget.restaurantId);
              if (restaurantCart == null || restaurantCart.items.isEmpty) {
                return const SizedBox.shrink();
              }
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: AppTheme.textPrimaryColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(
                            restaurantId: widget.restaurantId,
                            selectedBranch: widget.selectedBranch,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${restaurantCart.totalItems}',
                        style: TextStyle(
                          color: AppTheme.surfaceColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final restaurantCart = cart.getCartForRestaurant(widget.restaurantId);
          if (restaurantCart == null || restaurantCart.items.isEmpty) {
            return const SizedBox.shrink();
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${restaurantCart.totalItems} items',
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${restaurantCart.totalPrice.toStringAsFixed(2)} EGP',
                        style: TextStyle(
                          color: AppTheme.secondaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  text: 'View Cart',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(
                          restaurantId: widget.restaurantId,
                          selectedBranch: widget.selectedBranch,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Error loading restaurant details',
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              _error!,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            AppButton(
              text: 'Retry',
              onPressed: _loadData,
            ),
          ],
        ),
      );
    }

    if (_restaurant == null) {
      return const Center(
        child: Text('Restaurant not found'),
      );
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [
                RestaurantHeader(
                  restaurant: _restaurant!,
                ),
                if (_branchInfo != null)
                  Container(
                    margin: const EdgeInsets.all(AppTheme.spacingM),
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                      boxShadow: AppTheme.shadowSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoColumn(
                          Icons.table_bar,
                          '${_branchInfo!.freeTables}',
                          'Free Tables',
                        ),
                        _buildInfoColumn(
                          Icons.queue,
                          '${_branchInfo!.ordersInQueue}',
                          'Orders in Queue',
                        ),
                        _buildInfoColumn(
                          Icons.timer,
                          _formatWaitingTime(_branchInfo!.averageWaitingTime),
                          'Est. Waiting Time',
                        ),
                      ],
                    ),
                  ),
                CategoryTabs(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              ],
            ),
          ),
        ];
      },
      body: Builder(
        builder: (context) {
          return MenuItemGrid(
            items: _getFilteredItems(),
            restaurant: _restaurant!,
            selectedBranch: widget.selectedBranch,
          );
        },
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}