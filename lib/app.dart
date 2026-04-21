import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/account_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/search_screen.dart';
import 'screens/results_screen.dart';
import 'screens/purchase_screen.dart';
import 'providers/auth_provider.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.value != null;
      final isOnAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isOnAuthRoute) return '/login';
      if (isLoggedIn && isOnAuthRoute) return '/search';
      return null;
    },
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
});
