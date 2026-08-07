import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'src/config/theme.dart';
import 'src/features/auth/auth_service.dart';
import 'src/features/auth/login_screen.dart';
import 'src/providers/job_provider.dart';
import 'src/features/dashboard/customer_dashboard_screen.dart';
import 'src/features/admin/screens/admin_dashboard_screen.dart';
import 'src/features/technician/screens/technician_dashboard_screen.dart';

import 'src/features/hr/screens/hr_dashboard_screen.dart';

void main() async {
  debugPrint('🚀 main: Starting app initialization...');

  try {
    debugPrint('⚙️ main: Ensuring Flutter binding is initialized...');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('✅ main: Flutter binding initialized');

    debugPrint('🔥 main: Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint(
          '⏰ main: Firebase initialization timed out after 10 seconds',
        );
        throw Exception('Firebase initialization timed out');
      },
    );
    debugPrint('✅ main: Firebase initialized successfully');

    debugPrint('🎨 main: Running app...');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) {
              debugPrint('👤 main: Creating AuthService...');
              return AuthService();
            },
          ),
          ChangeNotifierProxyProvider<AuthService, JobProvider>(
            create: (_) => JobProvider(),
            update: (context, auth, previous) => previous!..update(auth),
          ),
        ],
        child: const GabeMobileApp(),
      ),
    );
    debugPrint('✅ main: App started successfully');
  } catch (e, stack) {
    debugPrint('❌ main: FATAL ERROR during initialization: $e');
    debugPrint('📚 main: Stack trace: $stack');

    // Still try to run the app with an error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    e.toString(),
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
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

class GabeMobileApp extends StatelessWidget {
  const GabeMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gabe Mobile Auto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.user == null) {
            return const LoginScreen();
          }

          if (auth.role == 'admin') {
            return const AdminDashboardScreen();
          }

          if (auth.role == 'hr') {
            return const HRDashboardScreen();
          }

          if (auth.role == 'technician') {
            // Will need proper import at top of file
            return const TechnicianDashboardScreen();
          }

          // Default to customer dashboard
          return const CustomerDashboardScreen();
        },
      ),
    );
  }
}
