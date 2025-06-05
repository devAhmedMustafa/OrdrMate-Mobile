import 'Item.dart';
import 'Branch.dart';

class CartItem {
  final Item item;
  int quantity;

  CartItem({
    required this.item,
    this.quantity = 1,
  });

  double get totalPrice => item.price * quantity;
}

class RestaurantCart {
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;
  final String? branchId;
  final Branch branch;

  RestaurantCart({
    required this.restaurantId,
    required this.restaurantName,
    List<CartItem>? items,
    this.branchId,
    required this.branch,
  }) : items = items ?? [];

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(Item item) {
    final existingItemIndex = items.indexWhere((cartItem) => cartItem.item.id == item.id);

    if (existingItemIndex == -1) {
      items.add(CartItem(item: item));
    } else {
      items[existingItemIndex].quantity++;
    }
  }

  void removeItem(String itemId) {
    items.removeWhere((cartItem) => cartItem.item.id == itemId);
  }

  void updateQuantity(String itemId, int quantity) {
    final item = items.firstWhere((cartItem) => cartItem.item.id == itemId);
    if (quantity <= 0) {
      removeItem(itemId);
    } else {
      item.quantity = quantity;
    }
  }

  void clear() {
    items.clear();
  }
}