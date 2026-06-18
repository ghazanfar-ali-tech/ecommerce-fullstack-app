import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/views/admin_screens/product_management_screens/product_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteProduct(BuildContext context, String docId) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(docId)
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(
    BuildContext context,
    Map<String, dynamic> productData,
    String docId,
  ) {
    final nameController = TextEditingController(
      text: productData['productName'] ?? '',
    );
    final priceController = TextEditingController(
      text: productData['productPrice']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: productData['productDescription'] ?? '',
    );
    final discountController = TextEditingController(
      text: productData['productDiscount']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          backgroundColor: AppColors.cardBackground(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.08,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Edit Product',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _editField(
                          context: context,
                          controller: nameController,
                          label: 'Product Name',
                          icon: Icons.shopping_bag_outlined,
                        ),
                        const SizedBox(height: 12),
                        _editField(
                          context: context,
                          controller: priceController,
                          label: 'Price (Rs)',
                          icon: Icons.payments_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _editField(
                          context: context,
                          controller: discountController,
                          label: 'Discount (%)',
                          icon: Icons.discount_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _editField(
                          context: context,
                          controller: descriptionController,
                          label: 'Description',
                          icon: Icons.description_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(color: AppColors.border(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.primaryShadow,
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(docId)
                                  .update({
                                    'productName': nameController.text.trim(),
                                    'productPrice':
                                        int.tryParse(
                                          priceController.text.trim(),
                                        ) ??
                                        0,
                                    'productDiscount':
                                        int.tryParse(
                                          discountController.text.trim(),
                                        ) ??
                                        0,
                                    'productDescription': descriptionController
                                        .text
                                        .trim(),
                                  });
                              if (context.mounted) {
                                Navigator.pop(context);
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
                                        Text('Product updated successfully'),
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
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.all(12),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _editField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.textSecondary(context),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceVariant(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterProducts(
    List<QueryDocumentSnapshot> products,
  ) {
    if (searchQuery.isEmpty) {
      return products;
    }

    return products.where((doc) {
      final productData = doc.data() as Map<String, dynamic>;
      final name = (productData['productName'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF3B82F6),
        title: const Text(
          "All Products",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      width: 210,
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(Icons.search),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 0,
                          ),
                          hintText: "Search Products..",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 1),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductManagementScreen(),
                      ),
                    ),
                    child: Container(
                      height: 44,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.blue,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "+ Add Products",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allProducts = snapshot.data?.docs ?? [];
                  final filteredProducts = _filterProducts(allProducts);

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: AppColors.textHint(context),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            searchQuery.isEmpty
                                ? 'No products found'
                                : 'No products match your search',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final size = MediaQuery.of(context).size;
                  final isTablet = size.width > 600;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: isTablet ? 50 : 40,
                              child: Text(
                                'Image',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Product',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isTablet ? 90 : 70,
                              child: Text(
                                'Price',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isTablet ? 100 : 80,
                              child: Text(
                                'Actions',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final doc = filteredProducts[index];
                          final docId = doc.id;
                          final productData =
                              doc.data() as Map<String, dynamic>;

                          final productName =
                              productData['productName'] ?? 'N/A';
                          final productPrice =
                              (productData['productPrice'] ?? 0).toString();
                          final productImageUrls =
                              (productData['productImageUrls']
                                      as List<dynamic>?)
                                  ?.map((url) => url.toString())
                                  .toList() ??
                              [];
                          final productImage = productImageUrls.isNotEmpty
                              ? productImageUrls[0]
                              : '';

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: isTablet ? 14 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.border(context),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow(context),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: isTablet ? 50 : 42,
                                  height: isTablet ? 50 : 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant(context),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.border(context),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: productImage.isNotEmpty
                                        ? Image.network(
                                            productImage,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              size: 20,
                                              color: AppColors.textHint(
                                                context,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 20,
                                            color: AppColors.textHint(context),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    productName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                SizedBox(
                                  width: isTablet ? 90 : 70,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      r'$' + productPrice,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                SizedBox(
                                  width: isTablet ? 100 : 80,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _showEditDialog(
                                          context,
                                          productData,
                                          docId,
                                        ),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                            border: Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      GestureDetector(
                                        onTap: () =>
                                            _deleteProduct(context, docId),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppColors.errorLight,
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                            border: Border.all(
                                              color: AppColors.error
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 16,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
