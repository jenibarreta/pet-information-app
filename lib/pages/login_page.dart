import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isRegistering = false;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  static const Color cream = Color(0xFFFFF5EA);
  static const Color coral = Color(0xFFF28C75);
  static const Color cocoa = Color(0xFF594438);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: coral,
              size: 25,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: cocoa,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (isRegistering) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;
        showMessage('Account created successfully!');
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = 'Authentication failed. Please try again.';
      }

      showMessage(message, isError: true);
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    String? Function(String?)? validator,
  }) {
    final obscure = isConfirmPassword
        ? obscureConfirmPassword
        : obscurePassword;

    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscure,
      validator: validator,
      keyboardType: label == 'Email Address'
          ? TextInputType.emailAddress
          : TextInputType.text,
      autocorrect: false,
      enableSuggestions: !isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: cocoa),
        prefixIcon: Icon(icon, color: coral),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: cocoa,
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirmPassword) {
                      obscureConfirmPassword =
                          !obscureConfirmPassword;
                    } else {
                      obscurePassword = !obscurePassword;
                    }
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 19,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: cocoa.withValues(alpha: 0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: coral,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: coral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: coral,
            width: 1.8,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 25,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  // APP ICON
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cocoa.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      size: 55,
                      color: coral,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Pet Information App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: cocoa,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isRegistering
                        ? 'Create your account to get started.'
                        : 'Welcome! Sign in to manage your pets.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cocoa.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // LOGIN / REGISTRATION FORM
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: cocoa.withValues(alpha: 0.08),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 5),

                          // EMAIL
                          buildInput(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Email is required.';
                              }

                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(value.trim())) {
                                return 'Enter a valid email address.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 17),

                          // PASSWORD
                          buildInput(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required.';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters.';
                              }

                              return null;
                            },
                          ),

                          // CONFIRM PASSWORD
                          if (isRegistering) ...[
                            const SizedBox(height: 17),

                            buildInput(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              icon: Icons.lock_reset_rounded,
                              isPassword: true,
                              isConfirmPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password.';
                                }

                                if (value != _passwordController.text) {
                                  return 'Passwords do not match.';
                                }

                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 25),

                          // LOGIN / CREATE BUTTON
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : authenticate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: coral,
                                disabledBackgroundColor:
                                    coral.withValues(alpha: 0.6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 23,
                                      height: 23,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isRegistering
                                          ? 'CREATE ACCOUNT'
                                          : 'LOGIN',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // SWITCH LOGIN / REGISTER
                          Center(
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        isRegistering = !isRegistering;
                                        _formKey.currentState?.reset();

                                        _emailController.clear();
                                        _passwordController.clear();
                                        _confirmPasswordController.clear();

                                        obscurePassword = true;
                                        obscureConfirmPassword = true;
                                      });
                                    },
                              child: Text(
                                isRegistering
                                    ? 'Already have an account? Login'
                                    : "Don't have an account? Create one",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: cocoa,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    'Made with care for your furry friends',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cocoa.withValues(alpha: 0.65),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
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

