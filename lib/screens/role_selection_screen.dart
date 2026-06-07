import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Background Layer
            Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/AppsBackground.jpg'),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x80001a33).withOpacity(0.3),
                    const Color(0x80330066).withOpacity(0.4),
                    const Color(0x80003d99).withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // Content Layer
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Title
                      const SizedBox(height: 40),
                      const Text(
                        'Honkai Star Retail',
                        style: TextStyle(
                          color: AppColors.brightBlue,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pilih Jenis Akun Anda',
                        style: TextStyle(
                          color: AppColors.silver,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 80),

                      // Admin Card
                      _buildRoleCard(
                        context,
                        title: 'Admin',
                        subtitle: 'Kelola Resources & Light Cones',
                        icon: Icons.admin_panel_settings,
                        color: const Color(0xFFFF6B6B),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(role: 'admin'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // User Card
                      _buildRoleCard(
                        context,
                        title: 'User',
                        subtitle: 'Lihat & Beli Resources',
                        icon: Icons.person,
                        color: const Color(0xFF4ECDC4),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(role: 'user'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 60),

                      // Divider
                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.silver)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ATAU',
                              style: TextStyle(color: AppColors.silver),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.silver)),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Register as New User
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              color: AppColors.silver,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(
                                    role: 'user',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Daftar sebagai User',
                              style: TextStyle(
                                color: AppColors.brightBlue,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.silver,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
