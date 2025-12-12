import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/send_money_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/transactions_screen.dart';

void main() {
  runApp(const RemitHubApp());
}

class RemitHubApp extends StatelessWidget {
  const RemitHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RemitHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const HomeScreen(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    // Handle null or empty route names
    final routeName = settings.name ?? HomeScreen.routeName;

    switch (routeName) {
      case HomeScreen.routeName:
        return _materialRoute(const HomeScreen(), settings);
      case SendMoneyScreen.routeName:
        return _materialRoute(const SendMoneyScreen(), settings);
      case MarketplaceScreen.routeName:
        return _materialRoute(const MarketplaceScreen(), settings);
      case TransactionsScreen.routeName:
        return _materialRoute(const TransactionsScreen(), settings);
      case LoginScreen.routeName:
        return _materialRoute(const LoginScreen(), settings);
      case SignUpScreen.routeName:
        return _materialRoute(const SignUpScreen(), settings);
      default:
        return _materialRoute(
          const HomeScreen(),
          RouteSettings(
            name: HomeScreen.routeName,
            arguments: settings.arguments,
          ),
        );
    }
  }

  PageRouteBuilder<dynamic> _materialRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
