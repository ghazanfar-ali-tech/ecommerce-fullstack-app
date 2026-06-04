import 'dart:io';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/resources/components/product_fields.dart';
import 'package:ecommerceapp/view_model/admin_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProductManagementScreen extends StatelessWidget {
  ProductManagementScreen({super.key});

  final searchController = TextEditingController();
  final TextEditingController productTitleController = TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productDiscountController =
      TextEditingController();

  Future<void> _pickMultipleImages(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      final viewModel = Provider.of<AdminViewModel>(context, listen: false);
      for (var img in images) {
        viewModel.addProductImage(File(img.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border(context)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(
              title: 'Product Images',
              icon: Icons.photo_library_outlined,
            ),
            const SizedBox(height: 12),
            Consumer<AdminViewModel>(
              builder: (context, model, _) {
                return SizedBox(
                  height: size.width * 0.32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: model.productImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == model.productImages.length) {
                        return GestureDetector(
                          onTap: () => _pickMultipleImages(context),
                          child: Container(
                            width: size.width * 0.28,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1.5,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Add Image',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          Container(
                            width: size.width * 0.28,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.border(context),
                              ),
                              image: DecorationImage(
                                image: FileImage(model.productImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 14,
                            top: 4,
                            child: GestureDetector(
                              onTap: () => model.removeProductImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            _SectionLabel(
              title: 'Basic Information',
              icon: Icons.info_outline_rounded,
            ),
            const SizedBox(height: 12),
            productFields(
              hintName: "Product Title",
              icon: Icons.shopping_bag_outlined,
              minLines: 1,
              controller: productTitleController,
            ),

            const SizedBox(height: 20),

            _SectionLabel(
              title: 'Description',
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: 12),
            productFields(
              hintName: "Enter Product Description",
              icon: Icons.notes_rounded,
              minLines: 4,
              keyboardtype: TextInputType.multiline,
              controller: productDescriptionController,
            ),

            const SizedBox(height: 20),

            _SectionLabel(title: 'Category', icon: Icons.category_outlined),
            const SizedBox(height: 12),
            Consumer<AdminViewModel>(
              builder: (context, model, child) {
                if (model.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (model.errorMessage != null) {
                  return Text(
                    model.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        "Select a category",
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 14,
                        ),
                      ),
                      value: model.selectedCategory,
                      items: model.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.categoryName,
                          child: Row(
                            children: [
                              category.imageUrl != null &&
                                      category.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        category.imageUrl!,
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.category_outlined,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                              const SizedBox(width: 10),
                              Text(
                                category.categoryName,
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null)
                          model.setProductCategoryMethod(value);
                      },
                      buttonStyleData: const ButtonStyleData(
                        height: 52,
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        width: double.infinity,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.cardBackground(context),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(height: 54),
                      dropdownSearchData: DropdownSearchData(
                        searchController: searchController,
                        searchInnerWidgetHeight: 54,
                        searchInnerWidget: Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                            controller: searchController,
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search category...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary(context),
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceVariant(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return item.value!.toLowerCase().contains(
                            searchValue.toLowerCase(),
                          );
                        },
                      ),
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) searchController.clear();
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                        title: 'Price (Rs)',
                        icon: Icons.payments_outlined,
                      ),
                      const SizedBox(height: 12),
                      productFields(
                        hintName: "e.g. 1500",
                        icon: Icons.payments_outlined,
                        minLines: 1,
                        controller: productPriceController,
                        keyboardtype: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                        title: 'Discount (%)',
                        icon: Icons.discount_outlined,
                      ),
                      const SizedBox(height: 12),
                      productFields(
                        hintName: "e.g. 10",
                        icon: Icons.discount_outlined,
                        minLines: 1,
                        controller: productDiscountController,
                        keyboardtype: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Consumer<AdminViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.primaryShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (viewModel.productImages.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text("Please select at least one image"),
                                    ],
                                  ),
                                  backgroundColor: AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(12),
                                ),
                              );
                              return;
                            }
                            final price =
                                int.tryParse(
                                  productPriceController.text.trim(),
                                ) ??
                                0;
                            final discount =
                                int.tryParse(
                                  productDiscountController.text.trim(),
                                ) ??
                                0;
                            final success = await viewModel.addProduct(
                              productTitleController.text.trim(),
                              discount,
                              price,
                              productDescriptionController.text.trim(),
                              viewModel.productCategoryName ?? "",
                              viewModel.productCategoryImage ?? "",
                              viewModel.productImages,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text("Product added successfully!"),
                                    ],
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(12),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Add Product',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionLabel({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
