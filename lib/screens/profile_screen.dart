import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/purchase.dart';
import '../services/auth_service.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _purchaseService = PurchaseService();
  final ImagePicker _imagePicker = ImagePicker();

  User? _user;
  List<Purchase> _purchases = [];
  bool _isLoading = true;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    // Verify token and get user
    final userResult = await _authService.verifyToken();
    if (userResult['success']) {
      setState(() => _user = userResult['user']);

      // Get purchase history
      final purchaseResult = await _purchaseService.getPurchaseHistory();
      if (purchaseResult['success']) {
        setState(() => _purchases = purchaseResult['purchases']);
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleEditAvatar() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        await _uploadAvatar(photo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadAvatar(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _uploadAvatar(XFile imageFile) async {
    setState(() => _isUploadingAvatar = true);

    try {
      // Read image file dan convert ke base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Upload ke backend
      final result = await _authService.uploadAvatar(base64Image);

      if (mounted) {
        if (result['success']) {
          // Update user state dengan response baru
          setState(() {
            _user = result['user'];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profile berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Gagal upload foto'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingAvatar = false);
    }
  }

  ImageProvider _getAvatarImage() {
    if (_user?.avatarUrl == null || _user!.avatarUrl!.isEmpty) {
      // Placeholder if no avatar
      return NetworkImage(
        'https://via.placeholder.com/100?text=${_user?.username[0] ?? 'U'}',
      );
    }

    final avatarUrl = _user!.avatarUrl!;

    // Check if it's a base64 string (doesn't start with http/https)
    if (!avatarUrl.startsWith('http')) {
      try {
        // It's a base64 string, convert to MemoryImage
        final bytes = base64Decode(avatarUrl);
        return MemoryImage(bytes);
      } catch (e) {
        // If decoding fails, return placeholder
        return NetworkImage(
          'https://via.placeholder.com/100?text=${_user?.username[0] ?? 'U'}',
        );
      }
    }

    // It's a URL, use NetworkImage
    return NetworkImage(avatarUrl);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _authService.logout();

    if (result['success']) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
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
            _isLoading || _user == null
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.brightBlue),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                          AppColors.deepPurple,
                          AppColors.darkPurple,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar dengan Button Edit
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.brightBlue,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: _getAvatarImage(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Edit Button
                            if (!_isUploadingAvatar)
                              GestureDetector(
                                onTap: _handleEditAvatar,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.brightBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.deepPurple,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.white,
                                    size: 16,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.brightBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Username
                        Text(
                          _user!.username,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),

                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _user!.isAdmin
                                ? AppColors.neonPurple
                                : AppColors.brightBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _user!.isAdmin ? 'Admin' : 'User',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informasi Akun',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow('Email', _user!.email),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Nama Lengkap',
                                  '${_user!.firstName ?? '-'} ${_user!.lastName ?? ''}',
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Token Info
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kunci Keamanan',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkBluePurple,
                                    border: Border.all(color: AppColors.borderColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Token: ${_user!.id.toString()}***',
                                    style: const TextStyle(
                                      color: AppColors.silver,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      wordSpacing: 2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Purchase History
                        Text(
                          'Riwayat Pembelian',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),

                        if (_purchases.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  'Belum ada riwayat pembelian',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _purchases.length,
                            itemBuilder: (context, index) {
                              final purchase = _purchases[index];
                              final date = DateFormat('dd MMMM yyyy HH:mm', 'id_ID')
                                  .format(purchase.purchaseDate);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  purchase.resourceName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  purchase.resourceType,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '\$${purchase.totalPrice.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: AppColors.brightBlue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Qty: ${purchase.quantity}x @ \$${purchase.resourcePrice.toStringAsFixed(2)}',
                                            style: Theme.of(context).textTheme.labelSmall,
                                          ),
                                          Text(
                                            date,
                                            style: Theme.of(context).textTheme.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 24),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            onPressed: _handleLogout,
                            child: const Text('Keluar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lightGray,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.silver,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
