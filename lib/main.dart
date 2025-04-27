import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login.dart';
import 'dashboard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Si Kasir',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF133E87),
        fontFamily: 'Poppins', // Assuming you'll add this font
      ),
      home: SplashScreen(checkLoginStatus: _checkLoginStatus),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Future<bool> Function() checkLoginStatus;

  const SplashScreen({
    super.key,
    required this.checkLoginStatus,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Background animation controller
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Content animation controller
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Background color animation
    _backgroundColorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFF133E87),
    ).animate(_backgroundController);

    // Slide animation for content
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Fade animation for content
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeIn,
      ),
    );

    // Start the animations sequentially
    _backgroundController.forward().then((_) {
      _contentController.forward();
    });

    // Navigate to the next screen after a delay
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for animations and add additional delay
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final isLoggedIn = await widget.checkLoginStatus();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? DashboardScreen() : LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            color: _backgroundColorAnimation.value,
            child: Stack(
              children: [
                // Background design elements
                Positioned(
                  top: -50,
                  right: -50,
                  child: AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _backgroundController.value * 0.7,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -80,
                  child: AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _backgroundController.value * 0.7,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Content
                Center(
                  child: AnimatedBuilder(
                    animation: _contentController,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo container with shadow
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/produk/logo.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // App name with creative styling
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'SiKasir',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Tagline - Now centered with additional constraints
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Text(
                                  'Kelola Bisnis Jadi Mudah? Si Kasir Jawabannya!',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 60),

                              // Custom loading indicator
                              SizedBox(
                                width: 40,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _contentController,
                                    builder: (context, _) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: 40 * _contentController.value,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
