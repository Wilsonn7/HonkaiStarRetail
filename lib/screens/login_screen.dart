import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';
import 'oauth_webview_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'admin' atau 'user'

  const LoginScreen({
    Key? key,
    this.role = 'user',
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    // Validasi format email dan domain sesuai role
    if (!email.contains('@') || email.isEmpty) {
      return false;
    }

    if (widget.role == 'user' && !email.endsWith('@gmail.com')) {
      return false;
    }

    if (widget.role == 'admin' && !email.endsWith('@admin.com')) {
      return false;
    }

    return true;
  }

  bool _validatePassword(String password) {
    // Validasi password minimal 8 karakter
    return password.length >= 8;
  }

  String _getEmailErrorMessage() {
    final email = _emailController.text;
    if (!email.contains('@') || email.isEmpty) {
      return 'Email harus valid dan mengandung @';
    }

    if (widget.role == 'user' && !email.endsWith('@gmail.com')) {
      return 'User harus menggunakan email @gmail.com';
    }

    if (widget.role == 'admin' && !email.endsWith('@admin.com')) {
      return 'Admin harus menggunakan email @admin.com';
    }

    return '';
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    // Validasi email
    if (!_validateEmail(_emailController.text)) {
      setState(() {
        _emailError = _getEmailErrorMessage();
      });
      isValid = false;
    }

    // Validasi password
    if (!_validatePassword(_passwordController.text)) {
      setState(() {
        _passwordError = 'Password minimal 8 karakter';
      });
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    final result = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
      role: widget.role,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Login gagal'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String roleDisplay = widget.role == 'admin' ? '👑 ADMIN' : '👤 USER';
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBluePurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        title: Text(
          'Login sebagai $roleDisplay',
          style: const TextStyle(
            color: AppColors.brightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Background Layer (Always Full Screen)
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
                    'Galactic Resources & Light Cones',
                    style: TextStyle(
                      color: AppColors.silver,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                const SizedBox(height: 60),

                // Email requirement info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.role == 'admin' 
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.role == 'admin' ? Colors.orange : Colors.blue,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.role == 'admin'
                        ? '👑 Admin: Gunakan email @admin.com'
                        : '👤 User: Gunakan email @gmail.com',
                    style: TextStyle(
                      color: widget.role == 'admin' ? Colors.orange : Colors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Email Input
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: widget.role == 'admin' 
                        ? 'contoh@admin.com'
                        : 'contoh@gmail.com',
                    errorText: _emailError,
                    prefixIcon: const Icon(Icons.email, color: AppColors.brightBlue),
                  ),
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password Input
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Masukkan password anda',
                    errorText: _passwordError,
                    prefixIcon: const Icon(Icons.lock, color: AppColors.brightBlue),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: AppColors.white),
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.darkBluePurple,
                              ),
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 20),

                // Google Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await OAuthHandler.handleOAuthLogin(
                        context,
                        'google',
                      );

                      if (result['success'] == true) {
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['error'] ?? 'Login Google gagal'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Login dengan Google'),
                  ),
                ),
                const SizedBox(height: 12),

                // Facebook Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await OAuthHandler.handleOAuthLogin(
                        context,
                        'facebook',
                      );

                      if (result['success'] == true) {
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['error'] ?? 'Login Facebook gagal'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Login dengan Facebook'),
                  ),
                ),
                const SizedBox(height: 12),

                // Twitter Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await OAuthHandler.handleOAuthLogin(
                        context,
                        'twitter',
                      );

                      if (result['success'] == true) {
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['error'] ?? 'Login Twitter gagal'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Login dengan Twitter'),
                  ),
                ),
                const SizedBox(height: 40),

                // Register Link
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
                            builder: (_) => RegisterScreen(
                              role: widget.role,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Daftar di sini',
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
}
