import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/resource_service.dart';
import '../theme/app_theme.dart';

class AdminFormScreen extends StatefulWidget {
  final Resource? resource;

  const AdminFormScreen({
    Key? key,
    this.resource,
  }) : super(key: key);

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _resourceService = ResourceService();

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;
  late TextEditingController _priceController;

  String? _nameError;
  String? _typeError;
  String? _stockError;
  String? _priceError;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.resource?.name ?? '');
    _typeController = TextEditingController(text: widget.resource?.type ?? '');
    _descriptionController = TextEditingController(text: widget.resource?.description ?? '');
    _stockController = TextEditingController(text: widget.resource?.stock.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.resource?.imageUrl ?? '');
    _priceController = TextEditingController(text: widget.resource?.price.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _nameError = null;
      _typeError = null;
      _stockError = null;
      _priceError = null;
    });

    bool isValid = true;

    if (_nameController.text.isEmpty) {
      setState(() => _nameError = 'Nama produk tidak boleh kosong');
      isValid = false;
    }

    if (_typeController.text.isEmpty) {
      setState(() => _typeError = 'Tipe produk tidak boleh kosong');
      isValid = false;
    }

    if (_stockController.text.isEmpty || int.tryParse(_stockController.text) == null) {
      setState(() => _stockError = 'Stok harus berupa angka');
      isValid = false;
    }

    if (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null) {
      setState(() => _priceError = 'Harga harus berupa angka');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleSave() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> result;

    if (widget.resource != null) {
      // Update existing resource
      result = await _resourceService.updateResource(
        id: widget.resource!.id,
        name: _nameController.text,
        type: _typeController.text,
        description: _descriptionController.text,
        stock: int.parse(_stockController.text),
        imageUrl: _imageUrlController.text,
        price: double.parse(_priceController.text),
      );
    } else {
      // Create new resource
      result = await _resourceService.createResource(
        name: _nameController.text,
        type: _typeController.text,
        description: _descriptionController.text,
        stock: int.parse(_stockController.text),
        imageUrl: _imageUrlController.text,
        price: double.parse(_priceController.text),
      );
    }

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context, true);
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
        title: Text(widget.resource != null ? 'Edit Produk' : 'Tambah Produk Baru'),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Nama Produk
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk',
                    hintText: 'Masukkan nama produk',
                    errorText: _nameError,
                    prefixIcon: const Icon(Icons.shopping_bag, color: AppColors.brightBlue),
                ),
                style: const TextStyle(color: AppColors.white),
              ),
              const SizedBox(height: 20),

              // Tipe Produk
              TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Tipe Produk',
                  hintText: 'Contoh: Currency, Light Cone, Material',
                  errorText: _typeError,
                  prefixIcon: const Icon(Icons.category, color: AppColors.brightBlue),
                ),
                style: const TextStyle(color: AppColors.white),
              ),
              const SizedBox(height: 20),

              // Deskripsi
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  hintText: 'Masukkan deskripsi produk',
                  prefixIcon: Icon(Icons.description, color: AppColors.brightBlue),
                ),
                style: const TextStyle(color: AppColors.white),
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Stok
            TextField(
              controller: _stockController,
              decoration: InputDecoration(
                labelText: 'Stok',
                hintText: 'Masukkan jumlah stok',
                errorText: _stockError,
                prefixIcon: const Icon(Icons.inventory, color: AppColors.brightBlue),
              ),
              style: const TextStyle(color: AppColors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Harga
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Harga',
                hintText: 'Masukkan harga produk',
                errorText: _priceError,
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.brightBlue),
              ),
              style: const TextStyle(color: AppColors.white),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),

            // URL Gambar
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Gambar (Opsional)',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.image, color: AppColors.brightBlue),
              ),
              style: const TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 30),

            // Preview Gambar
            if (_imageUrlController.text.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview Gambar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'URL Gambar tidak valid',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
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
                    : Text(widget.resource != null ? 'Simpan Perubahan' : 'Tambah Produk'),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
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
