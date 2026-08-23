import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/main_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/loads/presentation/loads_screen.dart';
import '../../features/shipment/presentation/shipments_screen.dart';
import '../../features/chat/presentation/conversations_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/load_detail/presentation/load_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/loads',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LoadsScreen(),
          ),
        ),
        GoRoute(
          path: '/shipments',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ShipmentsScreen(),
          ),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ConversationsScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/loads/:id',
      builder: (context, state) => LoadDetailScreen(
        loadId: state.pathParameters['id']!,
      ),
    ),
  ],
);
