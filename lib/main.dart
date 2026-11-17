import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PetInformationApp());
}

class PetInformationApp extends StatelessWidget {
  const PetInformationApp({super.key});

  static const Color cream = Color(0xFFFFF5EA);
  static const Color coral = Color(0xFFF28C75);
  static const Color cocoa = Color(0xFF594438);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Information App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coral,
          primary: coral,
          secondary: cocoa,
          surface: cream,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: cocoa,
          elevation: 0,
        ),
      ),
      home: const AnimatedSplashScreen(),
    );
  }
}

// ANIMATED SPLASH SCREEN
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() =>
      _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Show splash screen for 5 seconds.
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthGate(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PetInformationApp.cream,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/app_icon.png',
                    width: 155,
                    height: 155,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Pet Information App',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: PetInformationApp.cocoa,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'A little care for every paw 🐾',
                style: TextStyle(
                  fontSize: 14,
                  color: PetInformationApp.cocoa,
                ),
              ),

              const Spacer(),

              const SizedBox(
                width: 145,
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFFF5D8CC),
                  color: PetInformationApp.coral,
                  minHeight: 5,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Getting things ready...',
                style: TextStyle(
                  fontSize: 12,
                  color: PetInformationApp.cocoa,
                ),
              ),

              const SizedBox(height: 45),
            ],
          ),
        ),
      ),
    );
  }
}

// FIREBASE AUTHENTICATION CHECK
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: PetInformationApp.coral,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const DashboardPage();
        }

        return const LoginPage();
      },
    );
  }
}
