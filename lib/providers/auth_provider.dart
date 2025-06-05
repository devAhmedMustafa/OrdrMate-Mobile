import 'package:flutter/foundation.dart';
import 'package:ordrmate/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _error;
  String? _userEmail;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _authService.isAuthenticated;

  AuthProvider(this._authService);

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _userEmail = user['email'];
        _error = null;
      } else {
        _error = "Sign-in failed.";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _userEmail = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final isAuthenticated = _authService.isAuthenticated;
      if (isAuthenticated) {
        _userEmail = await _authService.getEmail();
        _error = null;
      } else {
        _userEmail = null;
        _error = "User not authenticated.";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}