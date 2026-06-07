import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/resource_service.dart';
import '../services/purchase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';
import 'admin_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int resourceId;

  const ProductDetailScreen({
    Key? key,
    required this.resourceId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _resourceService = ResourceService();
  final _purchaseService = PurchaseService();
  final _authService = AuthService();

  Resource? _resource;
  bool _isLoading = true;
  int _quantity = 1;
  bool _isAdmin = false;
  bool _isBuying = false;

  @override
  void initState() {
    super.initState();
    _loadResource();
    _checkUserRole();
  }

  Future<void> _loadResource() async {
    final result = await _resourceService.getResourceDetail(widget.resourceId);

    setState(() {
      if (result['success']) {
        _resource = result['resource'];
      }
      _isLoading = false;
    });
  }

  Future<void> _checkUserRole() async {
    final result = await _authService.verifyToken();
    if (result['success']) {
      setState(() {
        _isAdmin = result['user'].isAdmin;
      });
    }
  }

  Future<void> _handleBuy() async {
    if (_resource == null) return;

    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity harus lebih dari 0')),
      );
      return;
    }

    setState(() => _isBuying = true);

    final result = await _purchaseService.createPurchase(
      resourceId: _resource!.id,
      quantity: _quantity,
    );

    setState(() => _isBuying = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    if (_resource == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${_resource!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isBuying = true);

    final result = await _resourceService.deleteResource(_resource!.id);

    setState(() => _isBuying = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
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
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.brightBlue),
                    ),
                  )
                : _resource == null
                    ? const Center(
                        child: Text('Produk tidak ditemukan'),
                      )
                    : SingleChildScrollView(
                        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(ImageUtils.getAssetImagePath(_resource!.name)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product name
                            Text(
                              _resource!.name,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),

                            // Product type and price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tipe: ${_resource!.type}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stok: ${_resource!.stock}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: _resource!.isAvailable
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${_resource!.price.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: AppColors.brightBlue,
                                      ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            const Divider(color: AppColors.borderColor),
                            const SizedBox(height: 20),

                            // Description
                            Text(
                              'Deskripsi',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _resource!.description.isEmpty
                                  ? 'Tidak ada deskripsi'
                                  : _resource!.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),

                            const SizedBox(height: 30),

                            // Quantity control (for users)
                            if (!_isAdmin) ...[
                              Text(
                                'Jumlah Pembelian',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _quantity > 1
                                        ? () => setState(() => _quantity--)
                                        : null,
                                    icon: const Icon(Icons.remove_circle),
                                    color: AppColors.brightBlue,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.borderColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$_quantity',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _quantity < _resource!.stock
                                        ? () => setState(() => _quantity++)
                                        : null,
                                    icon: const Icon(Icons.add_circle),
                                    color: AppColors.brightBlue,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Total: \$${(_resource!.price * _quantity).toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.brightBlue,
                                    ),
                              ),
                              const SizedBox(height: 24),

                              // Buy button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: !_resource!.isAvailable || _isBuying
                                      ? null
                                      : _handleBuy,
                                  child: _isBuying
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
                                      : const Text('Beli Sekarang'),
                                ),
                              ),
                            ],

                            // Admin controls
                            if (_isAdmin) ...[
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AdminFormScreen(
                                              resource: _resource,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Edit Data'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isBuying ? null : _handleDelete,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                      ),
                                      child: _isBuying
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  AppColors.white,
                                                ),
                                              ),
                                            )
                                          : const Text('Hapus Barang'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
}
