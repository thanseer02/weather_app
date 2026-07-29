import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/weather/presentation/screens/home_screen.dart';
import '../features/weather/presentation/screens/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
