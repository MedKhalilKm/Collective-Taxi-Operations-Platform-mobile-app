import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_checkbox.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import 'main_navigation_screen.dart';
import 'sign_in_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms of service to continue.'),
          backgroundColor: Colors.deepOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Split full name into firstName and lastName
    final fullNameTrimmed = _fullNameController.text.trim();
    final nameParts = fullNameTrimmed.split(RegExp(r'\s+'));
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : firstName;

    // Generate username if empty based on email/name
    String username = _usernameController.text.trim();
    if (username.isEmpty) {
      username = _emailController.text.trim().split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '');
      if (username.length < 2) username = '${firstName.toLowerCase()}123';
    }

    // Phone number fallback if user entered standard phone
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      phone = '+216 12345678';
    }

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.register(
      email: _emailController.text.trim(),
      username: username,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phone,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result == RegisterResult.successAndLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Welcome.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else if (result == RegisterResult.successLoginFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully. Please sign in with your credentials.',
          ),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    } else {
      final err = authProvider.errorMessage ?? 'Registration failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Create an account',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Welcome back',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryYellowDark,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  CustomTextField(
                    label: 'Name',
                    controller: _fullNameController,
                    hintText: 'kamessi khalil',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Username Field
                  CustomTextField(
                    label: 'Username',
                    controller: _usernameController,
                    hintText: 'khalil123',
                    validator: Validators.validateUsername,
                  ),
                  const SizedBox(height: 18),

                  // Phone Number Field
                  CustomTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hintText: '+216 12345678',
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhoneNumber,
                  ),
                  const SizedBox(height: 18),

                  // Email Address Field
                  CustomTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    hintText: 'khalil@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 18),

                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hintText: '••••••••••••••••',
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 20),

                  // Terms and Conditions Checkbox
                  CustomCheckbox(
                    value: _agreeToTerms,
                    onChanged: (val) {
                      setState(() {
                        _agreeToTerms = val ?? false;
                      });
                    },
                    label: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                        children: [
                          TextSpan(
                            text: 'terms of service.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryYellowDark,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Terms of Service clicked'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Sign up Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppTheme.textDark,
                              ),
                            )
                          : const Text('Sign up'),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Or sign up with Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFE0E0E0),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'or sign up with',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFE0E0E0),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Social Sign Up
                  SocialButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Google Sign Up selected'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  // Already have an account? Sign in here
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const SignInScreen(),
                        ),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryYellowDark,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign in here',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryYellowDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
