import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ordrmate/pages/main_page.dart';
import 'package:ordrmate/providers/auth_provider.dart';
import 'package:ordrmate/providers/cart_provider.dart';
import 'package:ordrmate/services/auth_service.dart';
import 'package:ordrmate/services/order_service.dart';
import 'package:ordrmate/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  final statusController = StreamController<String>.broadcast();

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCVbxN_ticb2plxpxexR3lKDg5TmymBQq8",
        appId: "1:95702205905:android:69f33023c95148e4c88cf0",
        messagingSenderId: "95702205905",
        projectId: "ordrmate",
        storageBucket: "ordrmate.firebasestorage.app",
      ),
    );
    runApp(App(statusController: statusController));
  } catch (e) {
    statusController.add('Error during initialization: $e');
    // You might want to show an error screen here
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
}

class App extends StatefulWidget {
  final StreamController<String> statusController;

  const App({super.key, required this.statusController});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void dispose() {
    super.dispose();
    widget.statusController.close();
  }

  @override
  Widget build(BuildContext context){
    return MultiProvider(
      providers: [
        // Provide AuthService, passing the status controller
        ChangeNotifierProvider(create: (_) => AuthService(widget.statusController)),
        // Provide AuthProvider, using the AuthService instance
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(Provider.of<AuthService>(context, listen: false)),
          update: (context, authService, previousAuthProvider) => AuthProvider(authService),
        ),
        // Provide OrderService, using the AuthService instance
        ChangeNotifierProxyProvider<AuthService, OrderService>(
          create: (context) => OrderService(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, authService, previous) => OrderService(authService),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],

      child: MaterialApp(
        title: "OrdrMate",
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          return const MainPage();
        }),
      ),
    );
  }
}
