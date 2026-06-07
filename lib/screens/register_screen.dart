import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  final String role; // 'admin' atau 'user'

  const RegisterScreen({
    Key? key,
    this.role = 'user',
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _authService = AuthService();

  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  Future<void> _handleRegister() async {
    setState(() {
      _emailError = null;
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    // Validasi email
    if (!_validateEmail(_emailController.text)) {
      setState(() {
        _emailError = _getEmailErrorMessage();
      });
      isValid = false;
    }

    // Validasi username
    if (_usernameController.text.isEmpty) {
      setState(() {
        _usernameError = 'Username tidak boleh kosong';
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

    // Validasi confirm password
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Password tidak cocok';
      });
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    final result = await _authService.register(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
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
            content: Text(result['error'] ?? 'Registrasi gagal'),
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
        title: Text(
          'Daftar sebagai $roleDisplay',
          style: const TextStyle(
            color: AppColors.brightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

            // Username Input
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Masukkan username anda',
                errorText: _usernameError,
                prefixIcon: const Icon(Icons.person, color: AppColors.brightBlue),
              ),
              style: const TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 20),

            // First Name Input
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Depan (Opsional)',
                hintText: 'Masukkan nama depan',
                prefixIcon: Icon(Icons.badge, color: AppColors.brightBlue),
              ),
              style: const TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 20),

            // Last Name Input
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Belakang (Opsional)',
                hintText: 'Masukkan nama belakang',
                prefixIcon: Icon(Icons.badge, color: AppColors.brightBlue),
              ),
              style: const TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 20),

            // Password Input
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Minimal 8 karakter',
                errorText: _passwordError,
                prefixIcon: const Icon(Icons.lock, color: AppColors.brightBlue),
              ),
              obscureText: true,
              style: const TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 20),

            // Confirm Password Input
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                hintText: 'Ketik password lagi',
                errorText: _confirmPasswordError,
                prefixIcon: const Icon(Icons.lock, color: AppColors.brightBlue),
              ),
              obscureText: true,
              style: const TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 30),

            // Register Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
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
                    : const Text('Daftar'),
              ),
            ),
            const SizedBox(height: 20),

            // Already have account link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sudah punya akun? ',
                  style: TextStyle(
                    color: AppColors.silver,
                    fontFamily: 'Roboto',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text(
                    'Login di sini',
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
          ],
        ),
      ),
    );
  }
}
