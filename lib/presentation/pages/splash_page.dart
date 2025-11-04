import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixelator/core/constants/app_constants.dart';
import '../cubit/auth_cubit.dart';
import 'login_page.dart';
import 'home_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomePage(user: state.user)),
          );
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A202C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(
              //   'PIXELATOR',
              //   style: TextStyle(
              //     color: Color(0xFF4299E1),
              //     fontSize: 36,
              //     fontWeight: FontWeight.bold,
              //     letterSpacing: 3,
              //   ),
              // ),
              Image.asset(AppConstants.appLogo, width: 250),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4299E1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
