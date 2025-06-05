import 'package:flutter/material.dart';
import 'package:ordrmate/pages/login_page.dart';
import 'package:ordrmate/pages/main_cart_page.dart';
import 'package:ordrmate/pages/orders_page.dart';
import 'package:ordrmate/pages/restaurants_page.dart';
import 'package:ordrmate/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../ui/theme/app_theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>{

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Placeholder for Home Page
    const Center(child: Text('Home Page')),
    const RestaurantsPage(),
    // Placeholder for Orders Page
    const OrdersPage(),
    // Placeholder for Cart Page
    const MainCartPage(),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child){
        if (auth.isLoading){
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ),
          );
        }
        else if (!auth.isAuthenticated){
          return const LoginPage();
        } else {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: _pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: AppTheme.surfaceColor,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_rounded),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_rounded),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_rounded),
                  label: 'Cart',
                )
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textSecondaryColor,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),
          );
        }
      }
    );
  }
}