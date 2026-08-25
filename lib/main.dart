import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/loads/bloc/loads_bloc.dart';
import 'features/shipment/bloc/shipments_bloc.dart';
import 'features/profile/bloc/profile_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sl.init();
  runApp(const FreightApp());
}

class FreightApp extends StatefulWidget {
  const FreightApp({super.key});

  @override
  State<FreightApp> createState() => _FreightAppState();
}

class _FreightAppState extends State<FreightApp> {
  late final AuthBloc _authBloc;
  late final LoadsBloc _loadsBloc;
  late final ShipmentsBloc _shipmentsBloc;
  late final ProfileBloc _profileBloc;
  late final _router = createAppRouter(_authBloc);

  @override
  void initState() {
    super.initState();

    _authBloc = AuthBloc(sl.authRepository)..add(const AuthCheckRequested());
    _loadsBloc = LoadsBloc(sl.loadRepository);
    _shipmentsBloc = ShipmentsBloc(sl.shipmentRepository);
    _profileBloc = ProfileBloc(sl.userRepository);

    // Token yangilash ham ishlamay qolganda sessiyani yopamiz — aks holda
    // ilova "kirilgan" holatda qotib qoladi va login ekraniga yo'l qolmaydi.
    sl.apiClient.onAuthFailure = () {
      if (_authBloc.state is! AuthUnauthenticated) {
        _authBloc.add(const LogoutRequested());
      }
    };
  }

  @override
  void dispose() {
    sl.apiClient.onAuthFailure = null;
    _authBloc.close();
    _loadsBloc.close();
    _shipmentsBloc.close();
    _profileBloc.close();
    super.dispose();
  }

  /// Bloc'lar ilova darajasida yashaydi, shuning uchun logoutda ularni
  /// qo'lda tozalaymiz — aks holda keyingi foydalanuvchi oldingisining
  /// ma'lumotlarini ko'radi.
  void _onAuthChanged(BuildContext context, AuthState state) {
    if (state is AuthUnauthenticated) {
      _loadsBloc.add(const LoadsReset());
      _shipmentsBloc.add(const ShipmentsReset());
      _profileBloc.add(const ProfileReset());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _loadsBloc),
        BlocProvider.value(value: _shipmentsBloc),
        BlocProvider.value(value: _profileBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: _onAuthChanged,
        child: MaterialApp.router(
          title: 'Freight',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
