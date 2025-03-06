// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sylai2/services/auth_service.dart';
// import 'package:sylai2/widgets/common/custom_button.dart';
// import 'package:sylai2/widgets/common/loading_indicator.dart';

// enum VerificationType { email, phone }

// class OtpVerificationScreen extends ConsumerStatefulWidget {
//   final VerificationType verificationType;
//   final String target; // Email or phone number

//   const OtpVerificationScreen({
//     super.key,
//     required this.verificationType,
//     required this.target,
//     String? email,
//     String? phone,
//   });

//   @override
//   ConsumerState<OtpVerificationScreen> createState() =>
//       _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
//   final List<TextEditingController> _controllers = List.generate(
//     6,
//     (_) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

//   bool _isLoading = false;

//   @override
//   void dispose() {
//     for (final controller in _controllers) {
//       controller.dispose();
//     }
//     for (final focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _verifyOtp() async {
//     final otp = _controllers.map((c) => c.text).join();

//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter all 6 digits')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final authService = ref.read(authServiceProvider);

//       if (widget.verificationType == VerificationType.email) {
//         await authService.verifyEmailOtp(widget.target, otp);
//       } else {
//         await authService.verifyPhoneOtp(widget.target, otp);
//       }

//       // Create or update user record in the database
//       await authService.upsertUserRecord();

//       if (mounted) {
//         // Navigate back to login screen - the auth state listener will handle redirection
//         Navigator.of(context).popUntil((route) => route.isFirst);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Verification failed: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _handleDigitInput(int index, String value) {
//     if (value.length == 1) {
//       // Move focus to next field
//       if (index < 5) {
//         _focusNodes[index + 1].requestFocus();
//       } else {
//         // Last digit entered, hide keyboard
//         FocusScope.of(context).unfocus();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final targetType =
//         widget.verificationType == VerificationType.email ? 'email' : 'phone';
//     final obscuredTarget =
//         widget.verificationType == VerificationType.email
//             ? widget.target.replaceRange(2, widget.target.indexOf('@'), '****')
//             : widget.target.replaceRange(3, widget.target.length - 3, '******');

//     return Scaffold(
//       appBar: AppBar(title: const Text('Verify OTP')),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.security_outlined,
//                 size: 64,
//                 color: Color(0xFF7B61FF),
//               ),
//               const SizedBox(height: 32),
//               Text(
//                 'Enter verification code',
//                 style: Theme.of(context).textTheme.headlineSmall,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'We have sent a 6-digit code to your $targetType\n$obscuredTarget',
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 48),

//               // OTP input fields
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(6, (index) {
//                   return SizedBox(
//                     width: 50,
//                     height: 64,
//                     child: TextFormField(
//                       controller: _controllers[index],
//                       focusNode: _focusNodes[index],
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       maxLength: 1,
//                       style: const TextStyle(fontSize: 24),
//                       decoration: InputDecoration(
//                         counterText: '',
//                         contentPadding: EdgeInsets.zero,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Theme.of(context).cardColor,
//                       ),
//                       onChanged: (value) => _handleDigitInput(index, value),
//                     ),
//                   );
//                 }),
//               ),

//               const SizedBox(height: 48),
//               _isLoading
//                   ? const LoadingIndicator()
//                   : CustomButton(text: 'Verify', onPressed: _verifyOtp),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Use a different method'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sylai2/screens/home/home_screen.dart';
import 'package:sylai2/services/auth_service.dart';
import 'package:sylai2/widgets/common/custom_button.dart';
import 'package:sylai2/widgets/common/loading_indicator.dart';

enum VerificationType { email, phone }

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final VerificationType verificationType;
  final String target;
  final String? password;
  final bool isLogin;

  const OtpVerificationScreen({
    required this.verificationType,
    required this.target,
    this.password,
    this.isLogin = true,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final response =
          widget.verificationType == VerificationType.email
              ? await authService.verifyEmailOtp(
                widget.target,
                _otpController.text,
              )
              : await authService.verifyPhoneOtp(
                widget.target,
                _otpController.text,
              );

      // Store authentication data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', response.user!.id);
      await prefs.setString('auth_token', response.session!.accessToken);

      // Create or update user record
      await authService.upsertUserRecord();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter the verification code sent to your ${widget.verificationType == VerificationType.email ? 'email' : 'phone'}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.target,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  hintText: 'Enter OTP code',
                  prefixIcon: Icon(
                    widget.verificationType == VerificationType.email
                        ? Icons.email_outlined
                        : Icons.sms_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const LoadingIndicator()
                  : CustomButton(text: 'Verify', onPressed: _verifyOtp),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
