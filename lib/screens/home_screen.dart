import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/resource_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';
import 'product_detail_screen.dart';
import 'admin_form_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _resourceService = ResourceService();
  final _authService = AuthService();
  final _searchController = TextEditingController();

  List<Resource> _resources = [];
  List<Resource> _filteredResources = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedType;
  bool _isAdmin = false;
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Currency',
    'Light Cone',
    'Material',
  ];

  @override
  void initState() {
    super.initState();
    _loadResources();
    _checkUserRole();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkUserRole() async {
    final result = await _authService.verifyToken();
    if (result['success']) {
      setState(() {
        _isAdmin = result['user'].isAdmin;
      });
    }
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _resourceService.getResources(type: _selectedType);

    setState(() {
      if (result['success']) {
        _resources = result['resources'];
        _filteredResources = _resources;
      } else {
        _resources = [];
        _filteredResources = [];
        _errorMessage = result['error'];
      }
      _isLoading = false;
    });
  }

  void _filterResources(String query) {
    setState(() {
      _filteredResources = _resources
          .where(
            (resource) =>
                resource.name.toLowerCase().contains(query.toLowerCase()) ||
                resource.type.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Semua') {
        _selectedType = null;
      } else {
        _selectedType = category;
      }
    });
    _loadResources();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Honkai Star Retail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminFormScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
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
            RefreshIndicator(
              onRefresh: _loadResources,
              child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterResources,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.brightBlue,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.brightBlue,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterResources('');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Category filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) => _filterByCategory(category),
                        selectedColor: AppColors.brightBlue,
                        backgroundColor: AppColors.deepPurple,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.darkBluePurple
                              : AppColors.silver,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Products grid
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.brightBlue,
                      ),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (_filteredResources.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Tidak ada produk ditemukan',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: _filteredResources.length,
                  itemBuilder: (context, index) {
                    final resource = _filteredResources[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(resourceId: resource.id),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.brightBlue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          color: AppColors.darkBluePurple.withOpacity(0.8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Product Image (Left)
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage(ImageUtils.getAssetImagePath(resource.name)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: !resource.isAvailable
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.black.withOpacity(0.6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Out of Stock',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: AppColors.error,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                // Product Info (Right)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Name and Type
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            resource.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.white,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.brightBlue.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              resource.type,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: AppColors.brightBlue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Price and Button
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${resource.price.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  color: AppColors.brightBlue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: resource.isAvailable
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ProductDetailScreen(resourceId: resource.id),
                                                      ),
                                                    );
                                                  }
                                                : null,
                                            icon: const Icon(Icons.shopping_cart, size: 16),
                                            label: const Text('Beli'),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              backgroundColor: AppColors.brightBlue,
                                              disabledBackgroundColor:
                                                  AppColors.brightBlue.withOpacity(0.4),
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
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
