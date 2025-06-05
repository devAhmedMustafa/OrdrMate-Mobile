import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../ui/components/app_button.dart';
import '../ui/theme/app_theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Image
                  Image.asset(
                    'assets/images/OrdrMate.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  // Google Sign In Button
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      if (auth.isLoading) {
                        return const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        );
                      }

                      if (auth.error != null) {
                        return Column(
                          children: [
                            Text(
                              auth.error!,
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            AppButton(
                              text: 'Retry Sign In',
                              onPressed: () => auth.signInWithGoogle(),
                              isSecondary: true,
                              icon: Icons.refresh,
                            ),
                          ],
                        );
                      }

                      return AppButton(
                        text: 'Sign in with Google',
                        onPressed: () => auth.signInWithGoogle(),
                        icon: Icons.g_mobiledata,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}