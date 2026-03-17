import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ecommerceapp/models/category_model.dart';
import 'package:ecommerceapp/view_model/admin_view_model.dart';
import 'package:ecommerceapp/views/admin_screens/brand_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  final TextEditingController _searchController = TextEditingController();


  final List<String> sortItems = [
    'A → Z',
    'Z → A',
  'Date',
  'Total Items',
];
String? selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadCategories();
    });
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
      _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

 void _showAddCategoryDialog() {
  _categoryNameController.clear();
  _selectedImage = null;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _categoryNameController,
                  
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  InkWell(
                    onTap: () async {
                      await _pickImage();
                      setState(() {});
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50),
                                SizedBox(height: 8),
                                Text('Tap to select image'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              Consumer<AdminViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            bool success = await viewModel.addCategory(
                              _categoryNameController.text.trim(),
                              _selectedImage,
                            );

                            if (!mounted) return;

                            if (success) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Category added')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                      viewModel.errorMessage ??
                                          'Something went wrong'),
                                ),
                              );
                            }
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 18,
                      ),
                    ),

                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Add Category",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}

 void _showEditCategoryDialog(Category category) {
  _categoryNameController.text = category.categoryName;
  _selectedImage = null;

  final categoryViewModel = context.read<AdminViewModel>();

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: "Category Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  await _pickImage();
                  setState(() {}); 
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            category.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap image to change',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          Consumer<AdminViewModel>(
            builder: (context, model, child) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                ),
                onPressed: model.isLoading
                    ? null
                    : () async {
                        bool success = await categoryViewModel.updateCategory(
                          category.id,
                          _categoryNameController.text.trim(),
                          _selectedImage,
                          category.imageUrl,
                        );

                        if (success && dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Category updated successfully')),
                          );
                        } else if (dialogContext.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(categoryViewModel.errorMessage ?? 'Failed to update category'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: model.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.categoryName}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final categoryViewModel = context.read<AdminViewModel>();
              bool success = await categoryViewModel.deleteCategory(category.id);

              if (success && mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category deleted successfully')),
                );
              } else if (mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(categoryViewModel.errorMessage ?? 'Failed to delete category'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        title: const Text('Category Management'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
               Expanded(
      child: TextFormField(
        controller: _searchController,
        onChanged: (value) {
                setState(() {});
              },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: "Search category",
          border: OutlineInputBorder(),
        ),
      ),
    ),
                InkWell(
                  onTap: _showAddCategoryDialog,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.blue,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "+ Add Category",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<AdminViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  color: Colors.green[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Categories (${viewModel.categories.length})",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10,),
                      
                      SizedBox(
                        height: 50,
  width: 150,
  child: DropdownButtonFormField2<String>(
    isExpanded: true,
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8), 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    hint: const Text(
      'Sort By:',
      style: TextStyle(fontSize: 12),
    ),
    items: sortItems
        .map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 12),
              ),
            ))
        .toList(),
    onChanged: (value) {
  setState(() {
    selectedValue = value;

    final categories = context.read<AdminViewModel>().categories;

    if (value == 'A → Z') {
      categories.sort((a, b) => a.categoryName.compareTo(b.categoryName));
    } else if (value == 'Z → A') {
      categories.sort((a, b) => b.categoryName.compareTo(a.categoryName));
    } else if (value == 'Date') {
      categories.sort((a, b) => b.createdAt.compareTo(a.createdAt)); 
    } else if (value == 'Total Items') {
      categories.sort((a, b) => b.totalItems.compareTo(a.totalItems));
    }
  });
},

    buttonStyleData: const ButtonStyleData(
      height: 40, 
      padding: EdgeInsets.symmetric(horizontal: 8),
    ),
    iconStyleData: const IconStyleData(
      icon: Icon(Icons.arrow_drop_down, color: Colors.black45),
      iconSize: 20,
    ),
    dropdownStyleData: DropdownStyleData(
      maxHeight: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    menuItemStyleData: const MenuItemStyleData(
      height: 35, // smaller menu item height
      padding: EdgeInsets.symmetric(horizontal: 8),
    ),
  ),
)

                     
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<AdminViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.categories.isEmpty) {
                    return const Center(
                      child: Text('No categories found. Add your first category!'),
                    );
                  }

                  final query = _searchController.text.toLowerCase();

final filteredCategories = viewModel.categories.where((category) {
  return query.isEmpty ||
      category.categoryName.toLowerCase().contains(query);
}).toList();
      
                  return ListView.builder(
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
 

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(category.imageUrl),
                            onBackgroundImageError: (_, __) {},
                            child: category.imageUrl.isEmpty
                                ? const Icon(Icons.category)
                                : null,
                          ),
                          title: Text(category.categoryName),
                          subtitle: Text("Total items: ${category.totalItems}"),
                       trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.branding_watermark, color: Colors.orange),
      tooltip: 'Manage Brands',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BrandManagementScreen(category: category),
          ),
        );
      },
    ),
    IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () => _showEditCategoryDialog(category),
    ),
    IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => _showDeleteConfirmation(category),
    ),
  ],
),
                        ),
                      );
                    },
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