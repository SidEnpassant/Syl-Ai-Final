import 'package:flutter/material.dart';
import 'package:sylai2/models/syllabus_model.dart';
import 'package:sylai2/screens/auth/google_auth_screen.dart';
import 'package:sylai2/screens/auth/login_screen.dart';
import 'package:sylai2/screens/home/chat_screen.dart';
import 'package:sylai2/screens/home/home_screen.dart';
import 'package:sylai2/screens/home/resources_screen.dart';
import 'package:sylai2/screens/home/upload_screen.dart';
import 'package:sylai2/screens/settings/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      // case '/otp_verification':
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(
      //     builder: (_) => OtpVerificationScreen(
      //       email: args['email'] as String?,
      //       phone: args['phone'] as String?, verificationType: , target: '',
      //     ),
      //   );

      case '/google_auth':
        return MaterialPageRoute(builder: (_) => const GoogleAuthScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/chat':
        return MaterialPageRoute(builder: (_) => const ChatScreen());

      case '/upload':
        return MaterialPageRoute(builder: (_) => const UploadScreen());

      case '/resources':
        final syllabus = settings.arguments as SyllabusModel;
        return MaterialPageRoute(
          builder: (_) => ResourcesScreen(syllabus: syllabus),
        );

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}

class AppNavigation {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState get navigator => navigatorKey.currentState!;

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigator.pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return navigator.pushReplacementNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    return navigator.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack() {
    return navigator.pop();
  }
}
