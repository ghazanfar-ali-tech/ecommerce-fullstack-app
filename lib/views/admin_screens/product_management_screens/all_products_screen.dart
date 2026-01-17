
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

  void _showEditDialog(BuildContext context, Map<String, dynamic> productData, String docId) {
    final nameController = TextEditingController(text: productData['productName'] ?? '');
    final priceController = TextEditingController(text: productData['productPrice']?.toString() ?? '');
    final descriptionController = TextEditingController(text: productData['productDescription'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(docId)
                    .update({
                  'productName': nameController.text,
                  'productPrice': double.tryParse(priceController.text) ?? 0,
                  'productDescription': descriptionController.text,
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterProducts(List<QueryDocumentSnapshot> products) {
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
        title: const Text("All Products"),
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
                    child: TextFormField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductManagementScreen())),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blue,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Products"),
                  const Text("Price"),
                  const Text("Action"),
                ],
              ),
              const SizedBox(height: 15),
              
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
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
                      child: Text(
                        searchQuery.isEmpty ? 'No products found' : 'No products match your search',
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final doc = filteredProducts[index];
                      final docId = doc.id;
                      final productData = doc.data() as Map<String, dynamic>;
                      
                      final productName = productData['productName'] ?? 'N/A';
                      final productPrice = (productData['productPrice'] ?? 0).toString();
                      final productImageUrls = (productData['productImageUrls'] as List<dynamic>?)
                              ?.map((url) => url.toString())
                              .toList() ??
                          [];
                      final productImage = productImageUrls.isNotEmpty ? productImageUrls[0] : '';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: productImage.isNotEmpty ? NetworkImage(productImage) : null,
                                child: productImage.isEmpty ? const Icon(Icons.image_not_supported) : null,
                              ),

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    productName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),

                              Text("\$ $productPrice"),

                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: IconButton(
                                      iconSize: 16,
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () {
                                        _showEditDialog(context, productData, docId);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: IconButton(
                                      iconSize: 18,
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteProduct(context, docId);
                                      },
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}