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

class FreightApp extends StatelessWidget {
  const FreightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(sl.authRepository)),
        BlocProvider(create: (_) => LoadsBloc(sl.loadRepository)),
        BlocProvider(create: (_) => ShipmentsBloc(sl.shipmentRepository)),
        BlocProvider(create: (_) => ProfileBloc(sl.userRepository)),
      ],
      child: MaterialApp.router(
        title: 'Freight',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
