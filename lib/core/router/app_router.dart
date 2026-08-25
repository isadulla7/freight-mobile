import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/main_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/loads/presentation/loads_screen.dart';
import '../../features/loads/presentation/create_load_screen.dart';
import '../../features/shipment/presentation/shipments_screen.dart';
import '../../features/shipment/presentation/shipment_detail_screen.dart';
import '../../features/chat/presentation/conversations_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/load_detail/presentation/load_detail_screen.dart';
import '../../features/vehicles/presentation/vehicles_screen.dart';
import '../../features/vehicles/presentation/create_vehicle_screen.dart';
import '../../features/companies/presentation/companies_screen.dart';
import '../../features/companies/presentation/create_company_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/driver_profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// AuthBloc oqimini GoRouter tushunadigan Listenable'ga aylantiradi,
/// shunda auth holati o'zgarganda redirect qayta baholanadi.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(AuthBloc authBloc) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(authBloc.stream),
  redirect: (context, state) {
    final authState = authBloc.state;
    final isLoginRoute = state.matchedLocation == '/login';

    // Sessiya hali tekshirilmagan — login ekranida kutamiz, aks holda
    // saqlangan token bo'lsa ham foydalanuvchi login'ga uloqtiriladi.
    if (authState is AuthInitial || authState is AuthLoading) {
      return isLoginRoute ? null : '/login';
    }

    final isLoggedIn = authState is AuthAuthenticated;
    if (!isLoggedIn && !isLoginRoute) return '/login';
    if (isLoggedIn && isLoginRoute) return '/home';
    return null;
  },
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
      path: '/loads/create',
      builder: (context, state) => const CreateLoadScreen(),
    ),
    GoRoute(
      path: '/loads/:id',
      builder: (context, state) => LoadDetailScreen(
        loadId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/shipments/:id',
      builder: (context, state) => ShipmentDetailScreen(
        shipmentId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/chat/:conversationId',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return ChatScreen(
          conversationId: state.pathParameters['conversationId']!,
          title: extra?['title'] ?? 'Chat',
        );
      },
    ),
    GoRoute(
      path: '/vehicles',
      builder: (context, state) => const VehiclesScreen(),
    ),
    GoRoute(
      path: '/vehicles/create',
      builder: (context, state) => const CreateVehicleScreen(),
    ),
    GoRoute(
      path: '/companies',
      builder: (context, state) => const CompaniesScreen(),
    ),
    GoRoute(
      path: '/companies/create',
      builder: (context, state) => const CreateCompanyScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/driver-profile',
      builder: (context, state) => const DriverProfileScreen(),
    ),
  ],
);
