import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/pages/splash_page.dart';
import 'presentation/cubit/auth_cubit.dart';
import 'presentation/cubit/login_cubit.dart';

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
        BlocProvider(create: (_) => di.sl<LoginCubit>()),
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
      ],
      child: MaterialApp(
        title: 'PIXELATOR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF4299E1),
          scaffoldBackgroundColor: const Color(0xFF1A202C),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4299E1),
            secondary: Color(0xFF6B46C1),
            surface: Color(0xFF2D3748),
            background: Color(0xFF1A202C),
            error: Color(0xFFE53E3E),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            onBackground: Colors.white,
            onError: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2D3748),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          drawerTheme: const DrawerThemeData(
            backgroundColor: Color(0xFF1A202C),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF2D3748),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2D3748),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4299E1), width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.white70),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4299E1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4299E1),
            ),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
