import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (session == null) {
       
        if (!isAuthRoute && !isSplash) {
          return '/login';
        }
      } else {
      
        if (isAuthRoute) {
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: 'detail',
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return DetailScreen(
            videoId: id,
            title: extra?['title'] ?? '',
            description: extra?['description'] ?? '',
            imageUrl: extra?['imageUrl'] ?? '',
            category: extra?['category'] ?? '',
          );
        },
      ),
      GoRoute(
        name: 'favorites',
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        name: 'history',
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        name: 'profile',
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}

