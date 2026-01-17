import 'dart:io';

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
  final TextEditingController productDescriptionController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productDiscountController = TextEditingController();


  Future<void> _pickMultipleImages(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = await picker.pickMultiImage(
    imageQuality: 85,
  );

  if (images.isNotEmpty) {
    final viewModel = Provider.of<AdminViewModel>(context, listen: false);

    for (var img in images) {
      viewModel.addProductImage(File(img.path));
    }
  }
}


  @override
  Widget build(BuildContext context) {
  

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: const Text('Product Management'),
          
          ),
        centerTitle: true,
        elevation: 2,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

             Consumer<AdminViewModel>(
  builder: (context, model, _) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: model.productImages.length + 1,
        itemBuilder: (context, index) {
          if (index == model.productImages.length) {
            return GestureDetector(
              onTap: () => _pickMultipleImages(context),
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add),
              ),
            );
          }

          return Stack(
            children: [
              Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(model.productImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => model.removeProductImage(index),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
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


              const SizedBox(height: 30),

              const Text("Basic Information", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              productFields(
                hintName: "Product Title",
                icon: Icons.shopping_bag,
                minLines: 1,
                controller: productTitleController,
              ),

              const SizedBox(height: 20),

              const Text("Description", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              productFields(
                hintName: "Enter Product Description",
                icon: Icons.description,
                minLines: 4,
                keyboardtype: TextInputType.multiline,
                controller: productDescriptionController,
              ),

              const SizedBox(height: 20),

              const Text("Category", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Consumer<AdminViewModel>(
                builder: (context, model, child) {
                  if (model.isLoading) return const CircularProgressIndicator();
                  if (model.errorMessage != null) return Text(model.errorMessage!);

                  return DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: const Text("Select a category"),
                      value: model.selectedCategory,

                      items: model.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.categoryName,
                          child: Row(
                            children: [
                              category.imageUrl != null && category.imageUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        category.imageUrl!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.category, size: 40),
                              const SizedBox(width: 10),
                              Text(category.categoryName),
                            ],
                          ),
                        );
                      }).toList(),

                      onChanged: (value) {
                        if (value != null) model.setProductCategoryMethod(value);
                      },

                      buttonStyleData: const ButtonStyleData(
                        height: 50.0,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        width: double.infinity,
                      ),

                      dropdownStyleData: const DropdownStyleData(
                        maxHeight: 300.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                        ),
                      ),

                      menuItemStyleData: const MenuItemStyleData(height: 50.0),

                      dropdownSearchData: DropdownSearchData(
                        searchController: searchController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search category...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return item.value!.toLowerCase().contains(searchValue.toLowerCase());
                        },
                      ),

                      onMenuStateChange: (isOpen) {
                        if (!isOpen) searchController.clear();
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              const Text("Price", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              productFields(
                hintName: "Enter product price",
                icon: Icons.money,
                minLines: 1,
                controller: productPriceController,
                keyboardtype: TextInputType.number,
              ),

              const SizedBox(height: 20),

              const Text("Discount", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              productFields(
                hintName: "Enter discount percentage",
                icon: Icons.discount,
                minLines: 1,
                controller: productDiscountController,
                keyboardtype: TextInputType.number,
              ),

              const SizedBox(height: 30),

              Consumer<AdminViewModel>(
                builder: (context, viewModel, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              if (viewModel.productImages.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Please select at least one image")),
  );
  return;
}
                              int price = int.parse(productPriceController.text.trim());
                              int discount = int.parse(productDiscountController.text.trim()); 
final success = await viewModel.addProduct(
  productTitleController.text.trim(),
  discount,
  price,
  productDescriptionController.text.trim(),
  viewModel.productCategoryName ?? "",
  viewModel.productCategoryImage ?? "",
  viewModel.productImages,
);


                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Product added successfully!")),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Add Product',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
