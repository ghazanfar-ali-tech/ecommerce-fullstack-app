import 'dart:io';
import 'package:ecommerceapp/models/brand_model.dart';
import 'package:ecommerceapp/models/category_model.dart';
import 'package:ecommerceapp/view_model/admin_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BrandManagementScreen extends StatefulWidget {
  final Category category;
  const BrandManagementScreen({super.key, required this.category});

  @override
  State<BrandManagementScreen> createState() => _BrandManagementScreenState();
}

class _BrandManagementScreenState extends State<BrandManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _logoImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadBrandsForCategory(widget.category.id);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<File?> _pickSingleImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return picked != null ? File(picked.path) : null;
  }

  void _showAddBrandDialog() {
    _nameController.clear();
    _logoImage = null;
    context.read<AdminViewModel>().clearBrandIntroImages();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final viewModel = context.read<AdminViewModel>();

          return AlertDialog(
            title: const Text('Add Brand'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Brand Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Brand Logo',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final file = await _pickSingleImage();
                      if (file != null) {
                        setDialogState(() => _logoImage = file);
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _logoImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_logoImage!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40),
                                SizedBox(height: 6),
                                Text('Tap to select logo'),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Intro Product Images (max 3)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Consumer<AdminViewModel>(
                        builder: (_, vm, __) => Text(
                          '${vm.brandIntroImages.length}/3',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<AdminViewModel>(
                    builder: (_, vm, __) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...List.generate(vm.brandIntroImages.length, (i) {
                          return Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    vm.brandIntroImages[i],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => vm.removeBrandIntroImage(i),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close,
                                        size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  
                        if (vm.brandIntroImages.length < 3)
                          InkWell(
                            onTap: () async {
                              final file = await _pickSingleImage();
                              if (file != null) vm.addBrandIntroImage(file);
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.blue, style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_photo_alternate,
                                  color: Colors.blue, size: 32),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              Consumer<AdminViewModel>(
                builder: (_, vm, __) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 18),
                  ),
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final success = await vm.addBrand(
                            _nameController.text.trim(),
                            _logoImage,
                            widget.category.id,
                            vm.brandIntroImages,
                          );
                          if (!mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Brand added')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                    vm.errorMessage ?? 'Something went wrong'),
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Add Brand',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteBrandDialog(BrandModel brand) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Brand'),
        content: Text('Delete "${brand.name}" from ${widget.category.categoryName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final vm = context.read<AdminViewModel>();
              final success =
                  await vm.deleteBrand(widget.category.id, brand.id);
              if (!mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Brand deleted'
                      : vm.errorMessage ?? 'Failed to delete'),
                  backgroundColor: success ? null : Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brands — ${widget.category.categoryName}'),
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBrandDialog,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Brand', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, vm, _) {
          final brands = vm.brandsByCategory[widget.category.id] ?? [];

          if (vm.isLoading && brands.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (brands.isEmpty) {
            return const Center(
              child: Text('No brands yet. Tap "+ Add Brand" to create one.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final brand = brands[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  
                      Row(
                        children: [
                     
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(brand.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(brand.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.check_circle,
                                        color: Colors.blue, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${brand.introProductImages.length} intro product${brand.introProductImages.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteBrandDialog(brand),
                          ),
                        ],
                      ),
                   
                      if (brand.introProductImages.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: brand.introProductImages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                brand.introProductImages[i],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}