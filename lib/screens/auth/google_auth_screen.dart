import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sylai2/screens/home/home_screen.dart';
import 'package:sylai2/services/auth_service.dart';
import 'package:sylai2/utils/theme.dart';
import 'package:sylai2/widgets/common/custom_button.dart';
import 'package:sylai2/widgets/common/loading_indicator.dart';

class GoogleAuthScreen extends StatefulWidget {
  const GoogleAuthScreen({Key? key}) : super(key: key);

  @override
  _GoogleAuthScreenState createState() => _GoogleAuthScreenState();
}

class _GoogleAuthScreenState extends State<GoogleAuthScreen> {
  late final AuthService _authService;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    // Initialize AuthService with the Supabase client
    _authService = AuthService(Supabase.instance.client);
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithGoogle();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child:
            _isLoading
                ? const LoadingIndicator()
                : Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Study AI Assistant',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Sign in with Google to continue',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 50),
                      CustomButton(
                        text: 'Continue with Google',
                        icon: Icons.login,
                        onPressed: _signInWithGoogle,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back to Login',
                          style: TextStyle(color: AppTheme.accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
