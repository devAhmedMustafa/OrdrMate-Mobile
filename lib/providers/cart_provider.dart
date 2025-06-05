import 'package:flutter/foundation.dart';
import 'package:ordrmate/models/Branch.dart';
import 'package:ordrmate/models/Item.dart';
import 'package:ordrmate/models/RestaurantCart.dart';

class CartProvider with ChangeNotifier {

  final Map<String, RestaurantCart> _carts = {};

  Map<String, RestaurantCart> get carts => _carts;

  RestaurantCart? getCartForRestaurant(String restaurantId) {
    return _carts[restaurantId];
  }

  void addToCart(Item item, Branch branch){
    if (!_carts.containsKey(branch.restaurantId)){
      _carts[branch.restaurantId] = RestaurantCart(
        restaurantId: branch.restaurantId,
        restaurantName: branch.restaurantName,
        branchId: branch.id,
        branch: branch,
      );
    }

    _carts[branch.restaurantId]!.addItem(item);
    notifyListeners();
  }

  void removeFromCart(String item, Branch branch) {
    if (_carts.containsKey(branch.restaurantId)) {
      _carts[branch.restaurantId]!.removeItem(item);
      if (_carts[branch.restaurantId]!.items.isEmpty) {
        _carts.remove(branch.restaurantId);
      }
      notifyListeners();
    }
  }

  void updateItemQuantity(String item, Branch branch, int quantity) {
    if (_carts.containsKey(branch.restaurantId)) {
      _carts[branch.restaurantId]!.updateQuantity(item, quantity);
      if (_carts[branch.restaurantId]!.items.isEmpty) {
        _carts.remove(branch.restaurantId);
      }
      notifyListeners();
    }
  }

  void clearCart(String restaurantId) {
    if (_carts.containsKey(restaurantId)) {
      _carts.remove(restaurantId);
      notifyListeners();
    }
  }

  double getTotalPrice(String restaurantId) {
    if (_carts.containsKey(restaurantId)) {
      return _carts[restaurantId]!.totalPrice;
    }
    return 0.0;
  }

  int getTotalItems(String restaurantId) {
    if (_carts.containsKey(restaurantId)) {
      return _carts[restaurantId]!.totalItems;
    }
    return 0;
  }
}