import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/account_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/search_screen.dart';
import 'screens/results_screen.dart';
import 'screens/purchase_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/results',
      name: 'results',
      builder: (context, state) => const ResultsScreen(),
    ),
    GoRoute(
      path: '/purchase',
      name: 'purchase',
      builder: (context, state) => PurchaseScreen(),
    ),
    GoRoute(
      path: '/bookings',
      name: 'bookings',
      builder: (context, state) => BookingsScreen(),
    ),
    GoRoute(
      path: '/booking/:id',
      name: 'booking',
      builder: (context, state) =>
          BookingScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/account/:id',
      name: 'account',
      builder: (context, state) =>
          AccountScreen(id: state.pathParameters['id']!),
    ),
  ],
);
