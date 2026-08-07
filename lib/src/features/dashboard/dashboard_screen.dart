import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import 'customer_dashboard_screen.dart';

import '../admin/screens/admin_dashboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.user == null) {
          return const LoginScreen();
        }

        // Check for admin role
        if (authService.role == 'admin') {
          return const AdminDashboardScreen();
        }

        // Default to Customer Dashboard
        return const CustomerDashboardScreen();
      },
    );
  }
}
