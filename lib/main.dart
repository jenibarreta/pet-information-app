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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape =
                constraints.maxWidth > constraints.maxHeight;

            final logoSize = isLandscape ? 100.0 : 155.0;
            final titleSize = isLandscape ? 21.0 : 25.0;
            final topSpacing = isLandscape ? 8.0 : 25.0;
            final sectionSpacing = isLandscape ? 6.0 : 10.0;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Image.asset(
                          'assets/app_icon.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: topSpacing),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Pet Information App',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: PetInformationApp.cocoa,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    SizedBox(height: sectionSpacing),

                    const Text(
                      'A little care for every paw 🐾',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: PetInformationApp.cocoa,
                      ),
                    ),

                    SizedBox(height: isLandscape ? 16 : 35),

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
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: PetInformationApp.cocoa,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
