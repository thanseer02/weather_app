import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/animated_gradient_bg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _cloudController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _cloudAnimation1;
  late Animation<Offset> _cloudAnimation2;

  @override
  void initState() {
    super.initState();
    
    // Scale & Fade Animations
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    // Cloud floating animations
    _cloudController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    
    _cloudAnimation1 = Tween<Offset>(
      begin: const Offset(-0.05, 0),
      end: const Offset(0.05, 0),
    ).animate(CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut));
    
    _cloudAnimation2 = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: const Offset(-0.05, 0),
    ).animate(CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut));

    _fadeController.forward();
    _scaleController.forward();

    // Navigate automatically after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/home'); // Dummy route for now
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBg(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cloud 1
              SlideTransition(
                position: _cloudAnimation1,
                child: Transform.translate(
                  offset: const Offset(-80, -60),
                  child: const Icon(Icons.cloud, color: Colors.white54, size: 100),
                ),
              ),
              // Cloud 2
              SlideTransition(
                position: _cloudAnimation2,
                child: Transform.translate(
                  offset: const Offset(80, 40),
                  child: const Icon(Icons.cloud, color: Colors.white54, size: 80),
                ),
              ),
              // Logo (Scale and Fade)
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wb_sunny_rounded,
                        color: Colors.amber,
                        size: 120,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Weather App',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
