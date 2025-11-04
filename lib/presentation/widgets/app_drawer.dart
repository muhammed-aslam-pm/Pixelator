import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixelator/core/constants/app_constants.dart';
import '../cubit/logout_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../pages/login_page.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/utils/logger.dart';

class AppDrawer extends StatelessWidget {
  final UserEntity user;

  const AppDrawer({super.key, required this.user});

  String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A202C),
      child: SafeArea(
        child: Column(
          children: [
            // Header with user info
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1A202C)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   'GENESYS PIXELATOR',
                  //   style: TextStyle(
                  //     color: Color(0xFF4299E1),
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //     letterSpacing: 1.2,
                  //   ),
                  // ),
                  Image.asset(AppConstants.appLogo),

                  const SizedBox(height: 24),
                  // User avatar and info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFF2D3748),
                        child: Text(
                          getInitials(user.fullName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // if (user.roles.isNotEmpty) ...[
                            //   const SizedBox(height: 8),
                            //   Container(
                            //     padding: const EdgeInsets.symmetric(
                            //       horizontal: 8,
                            //       vertical: 4,
                            //     ),
                            //     decoration: BoxDecoration(
                            //       color: const Color(0xFF4299E1),
                            //       borderRadius: BorderRadius.circular(4),
                            //     ),
                            //     child: Text(
                            //       user.roles.first,
                            //       style: const TextStyle(
                            //         color: Colors.white,
                            //         fontSize: 11,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     ),
                            //   ),
                            // ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Spacer
            const Spacer(),
            // Logout button at bottom
            BlocListener<LogoutCubit, LogoutState>(
              listener: (context, state) {
                if (state is LogoutSuccess) {
                  // Update auth cubit to unauthenticated
                  context.read<AuthCubit>().setUnauthenticated();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                } else if (state is LogoutError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: BlocBuilder<LogoutCubit, LogoutState>(
                builder: (context, state) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white70),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      trailing: state is LogoutLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white54,
                            ),
                      onTap: state is LogoutLoading
                          ? null
                          : () {
                              AppLogger.i('Logout initiated');
                              context.read<LogoutCubit>().logout();
                            },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: const Color(0xFF2D3748),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
