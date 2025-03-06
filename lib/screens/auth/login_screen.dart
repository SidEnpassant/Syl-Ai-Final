// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sylai2/env.dart';
// import 'package:sylai2/screens/auth/otp_verification_screen.dart';
// import 'package:sylai2/screens/home/home_screen.dart';
// import 'package:sylai2/services/auth_service.dart';
// import 'package:sylai2/widgets/common/custom_button.dart';
// import 'package:sylai2/widgets/common/custom_textfield.dart';
// import 'package:sylai2/widgets/common/loading_indicator.dart';

// final loginTypeProvider = StateProvider<LoginType>((ref) => LoginType.email);
// final loginStateProvider = StateProvider<LoginState>(
//   (ref) => LoginState.emailEntry,
// );

// enum LoginType { email, phone }

// enum LoginState { emailEntry, login, register }

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;
//   bool _isEmailRegistered = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _checkEmailRegistration() async {
//     if (!_validateEmail()) return;

//     setState(() => _isLoading = true);

//     try {
//       final authService = ref.read(authServiceProvider);
//       // Add a method to your AuthService to check if email exists
//       // This is a placeholder - implement actual check in AuthService
//       _isEmailRegistered = await authService.isEmailRegistered(
//         _emailController.text.trim(),
//       );

//       // Update login state based on email registration status
//       ref.read(loginStateProvider.notifier).state =
//           _isEmailRegistered ? LoginState.login : LoginState.register;
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   bool _validateEmail() {
//     final email = _emailController.text.trim();
//     if (email.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please enter your email')));
//       return false;
//     }
//     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a valid email')),
//       );
//       return false;
//     }
//     return true;
//   }

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final authService = ref.read(authServiceProvider);
//       // Implement email/password sign in in your AuthService
//       await authService.signInWithEmailPassword(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       // User profile is automatically created in Supabase auth
//       await authService.upsertUserRecord();
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _handleRegister() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_passwordController.text != _confirmPasswordController.text) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final authService = ref.read(authServiceProvider);

//       // Implement email/password sign-up in your AuthService
//       await authService.signUpWithEmailPassword(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       // User profile is automatically created in Supabase auth
//       await authService.upsertUserRecord();

//       // Navigate to HomeScreen only after successful registration
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _handlePhoneLogin() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final authService = ref.read(authServiceProvider);
//       await authService.signInWithPhoneOtp(_phoneController.text.trim());

//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => OtpVerificationScreen(
//                   verificationType: VerificationType.phone,
//                   target: _phoneController.text.trim(),
//                 ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _handleGoogleLogin() async {
//     setState(() => _isLoading = true);

//     try {
//       final authService = ref.read(authServiceProvider);
//       await authService.signInWithGoogle();

//       // User profile is automatically created in Supabase auth
//       await authService.upsertUserRecord();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final loginType = ref.watch(loginTypeProvider);
//     final loginState = ref.watch(loginStateProvider);

//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // App logo and title
//                   Icon(
//                     Icons.school_outlined,
//                     size: 64,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     AppConstants.appName,
//                     style: Theme.of(context).textTheme.headlineMedium,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     AppConstants.appDescription,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 48),

//                   // Login type toggle
//                   SegmentedButton<LoginType>(
//                     segments: const [
//                       ButtonSegment(
//                         value: LoginType.email,
//                         label: Text('Email'),
//                         icon: Icon(Icons.email_outlined),
//                       ),
//                       ButtonSegment(
//                         value: LoginType.phone,
//                         label: Text('Phone'),
//                         icon: Icon(Icons.phone_android_outlined),
//                       ),
//                     ],
//                     selected: {loginType},
//                     onSelectionChanged: (Set<LoginType> selection) {
//                       ref.read(loginTypeProvider.notifier).state =
//                           selection.first;
//                       // Reset login state if switching between email and phone
//                       if (loginType != selection.first) {
//                         ref.read(loginStateProvider.notifier).state =
//                             selection.first == LoginType.email
//                                 ? LoginState.emailEntry
//                                 : LoginState.emailEntry;
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 24),

//                   // Login form based on login type and state
//                   if (loginType == LoginType.email) ...[
//                     // Email input
//                     CustomTextField(
//                       controller: _emailController,
//                       hintText: 'Email address',
//                       prefixIcon: Icons.email_outlined,
//                       keyboardType: TextInputType.emailAddress,
//                       enabled: loginState == LoginState.emailEntry,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         if (!RegExp(
//                           r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                         ).hasMatch(value)) {
//                           return 'Please enter a valid email';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     // Show password field for login or registration
//                     if (loginState == LoginState.login ||
//                         loginState == LoginState.register) ...[
//                       CustomTextField(
//                         controller: _passwordController,
//                         hintText: 'Password',
//                         prefixIcon: Icons.lock_outline,
//                         obscureText: _obscurePassword,
//                         suffix: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your password';
//                           }
//                           if (value.length < 6) {
//                             return 'Password must be at least 6 characters';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       // Show confirm password field for registration
//                       if (loginState == LoginState.register)
//                         CustomTextField(
//                           controller: _confirmPasswordController,
//                           hintText: 'Confirm Password',
//                           prefixIcon: Icons.lock_outline,
//                           obscureText: _obscureConfirmPassword,
//                           suffix: IconButton(
//                             icon: Icon(
//                               _obscureConfirmPassword
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _obscureConfirmPassword =
//                                     !_obscureConfirmPassword;
//                               });
//                             },
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please confirm your password';
//                             }
//                             if (value != _passwordController.text) {
//                               return 'Passwords do not match';
//                             }
//                             return null;
//                           },
//                         ),
//                     ],
//                   ] else
//                     CustomTextField(
//                       controller: _phoneController,
//                       hintText: 'Phone number (with country code)',
//                       prefixIcon: Icons.phone_outlined,
//                       keyboardType: TextInputType.phone,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your phone number';
//                         }
//                         if (!RegExp(r'^\+[0-9]{10,15}$').hasMatch(value)) {
//                           return 'Please enter a valid phone number with country code';
//                         }
//                         return null;
//                       },
//                     ),
//                   const SizedBox(height: 24),

//                   // Action buttons based on login type and state
//                   _isLoading
//                       ? const LoadingIndicator()
//                       : loginType == LoginType.email
//                       ? loginState == LoginState.emailEntry
//                           ? CustomButton(
//                             text: 'Continue',
//                             onPressed: _checkEmailRegistration,
//                           )
//                           : loginState == LoginState.login
//                           ? CustomButton(text: 'Login', onPressed: _handleLogin)
//                           : CustomButton(
//                             text: 'Register',
//                             onPressed: _handleRegister,
//                           )
//                       : CustomButton(
//                         text: 'Get OTP',
//                         onPressed: _handlePhoneLogin,
//                       ),

//                   if (loginState != LoginState.emailEntry &&
//                       loginType == LoginType.email)
//                     TextButton(
//                       onPressed: () {
//                         ref.read(loginStateProvider.notifier).state =
//                             LoginState.emailEntry;
//                         _passwordController.clear();
//                         _confirmPasswordController.clear();
//                       },
//                       child: const Text('Use a different email'),
//                     ),

//                   const SizedBox(height: 24),

//                   // Divider
//                   Row(
//                     children: [
//                       const Expanded(child: Divider()),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           'OR',
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                       ),
//                       const Expanded(child: Divider()),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // Google login button
//                   OutlinedButton.icon(
//                     onPressed: _isLoading ? null : _handleGoogleLogin,
//                     icon: const Icon(Icons.g_mobiledata, size: 24),
//                     label: const Text('Continue with Google'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sylai2/app_constants.dart';
import 'package:sylai2/screens/home/home_screen.dart';
import 'package:sylai2/services/auth_service.dart';
import 'package:sylai2/widgets/common/custom_button.dart';
import 'package:sylai2/widgets/common/custom_textfield.dart';
import 'package:sylai2/widgets/common/loading_indicator.dart';

final loginTypeProvider = StateProvider<LoginType>((ref) => LoginType.login);

enum LoginType { login, register }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final authToken = prefs.getString('auth_token');

    if (userId != null && authToken != null) {
      // Validate token with Supabase
      try {
        final authService = ref.read(authServiceProvider);
        final isValid = await authService.validateToken(authToken);

        if (isValid && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } catch (e) {
        // Token invalid, clear stored credentials
        await prefs.remove('user_id');
        await prefs.remove('auth_token');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      // Sign in with email and password directly
      final response = await authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Store authentication data
      if (response.session != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', response.user!.id);
        await prefs.setString('auth_token', response.session!.accessToken);
      }

      if (mounted) {
        // Navigate to home screen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      // Check if email already exists
      final emailExists = await authService.isEmailRegistered(
        _emailController.text.trim(),
      );

      if (emailExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already registered. Please login instead.'),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // Register user with email and password
      final response = await authService.signUpWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Store authentication data
      if (response.session != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', response.user!.id);
        await prefs.setString('auth_token', response.session!.accessToken);

        // Create user record in database
        await authService.upsertUserRecord();
      }

      if (mounted) {
        // Navigate to home screen on successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signInWithGoogle();

      // Store authentication data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', response.user!.id);
      await prefs.setString('auth_token', response.session!.accessToken);

      // Create user record
      await authService.upsertUserRecord();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginType = ref.watch(loginTypeProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo and title
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.appDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Login type toggle
                  SegmentedButton<LoginType>(
                    segments: const [
                      ButtonSegment(
                        value: LoginType.login,
                        label: Text('Login'),
                        icon: Icon(Icons.login_outlined),
                      ),
                      ButtonSegment(
                        value: LoginType.register,
                        label: Text('Register'),
                        icon: Icon(Icons.person_add_outlined),
                      ),
                    ],
                    selected: {loginType},
                    onSelectionChanged: (Set<LoginType> selection) {
                      ref.read(loginTypeProvider.notifier).state =
                          selection.first;
                      // Clear password fields when switching between login and register
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Email input
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field for registration
                  if (loginType == LoginType.register)
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),

                  // Action button
                  _isLoading
                      ? const LoadingIndicator()
                      : loginType == LoginType.login
                      ? CustomButton(text: 'Login', onPressed: _handleLogin)
                      : CustomButton(
                        text: 'Register',
                        onPressed: _handleRegister,
                      ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google login button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text('Continue with Google'),
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
