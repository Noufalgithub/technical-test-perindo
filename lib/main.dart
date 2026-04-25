import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:technical_test_superindo/core/service_locator.dart' as di;
import 'package:technical_test_superindo/presentation/bloc/auth_bloc.dart';
import 'package:technical_test_superindo/presentation/bloc/member_bloc.dart';
import 'package:technical_test_superindo/presentation/bloc/profile_bloc.dart';
import 'package:technical_test_superindo/core/theme/app_theme.dart';
import 'package:technical_test_superindo/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus())),
        BlocProvider(create: (_) => di.sl<MemberBloc>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
      ],
      child: MaterialApp(
        title: 'Register Offline',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashPage(),
        builder: (context, child) {
          return SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: child!,
          );
        },
      ),
    );
  }
}
