import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/views/home_screen/widgets/add_to_cart_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Wishlist",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 10),
        ],
      ),
      body: Consumer<StoreViewModel>(
        builder: (context, viewModel, child) {
          final favCount = viewModel.favList.length;
          
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: const Color.fromARGB(255, 236, 236, 236),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Text(
                          "$favCount ${favCount == 1 ? 'Item' : 'Items'}",
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("in your wishlist"),
                        const SizedBox(height: 15),
                      ],
                    ),
                addToCartButton(
  "Add all to Cart",
  Icons.shopping_cart_checkout_sharp,
  Colors.orange,
  () async {
    if (favCount > 0) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final cartBox = authVM.getCartBox();
      
      final countBefore = cartBox.length;
      await viewModel.addAllToCart(cartBox);
      final countAfter = cartBox.length;
      final addedCount = countAfter - countBefore;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addedCount == 0
                ? 'All items already in cart'
                : 'Added $addedCount item${addedCount == 1 ? '' : 's'} to cart',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  },
  Colors.white,
  16.0,
  18,
),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              Expanded(
                child: favCount == 0
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Your wishlist is empty",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Add items you love to your wishlist",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: favCount,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemBuilder: (context, index) {
                          final product = viewModel.favList[index];
                          
                          // Extract product details safely
                          final productName = product['productName'] ?? 'Unknown Product';
                          final productPrice = (product['productPrice'] ?? 0).toString();
                          final productCategory = product['categoryName'] ?? 'Category';
                          final productImages = product['productImageUrls'] as List?;
                          final imageUrl = (productImages != null && productImages.isNotEmpty)
                              ? productImages[0]
                              : null;
                          
                          return Card(
                            color: Colors.white,
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              height: 120,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    child: Container(
                                      width: 120,
                                      height: double.infinity,
                                      color: Colors.grey[100],
                                      child: imageUrl != null
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.image_outlined,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                );
                                              },
                                            )
                                          : Icon(
                                              Icons.image_outlined,
                                              size: 50,
                                              color: Colors.grey[400],
                                            ),
                                    ),
                                  ),
                                  
                                  // Product Details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                productName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                productCategory,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          // Price and Actions
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "\$$productPrice",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                GestureDetector(
  onTap: () async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final cartBox = authVM.getCartBox();
    final exists = cartBox.values.any((item) => item.productName == productName);
    
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productName already in cart'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      await viewModel.addSingleToCart(product, cartBox);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $productName to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  },
  child: const Icon(
    Icons.shopping_cart_outlined,
    size: 22,
    color: Colors.orange,
  ),
),
                                                  const SizedBox(width: 20),
                                                  
                                                  // Remove from Favorites Button
                                                  GestureDetector(
                                                    onTap: () {
                                                      viewModel.removeFromFavorites(productName);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Removed $productName from wishlist'),
                                                          duration: const Duration(seconds: 1),
                                                        ),
                                                      );
                                                    },
                                                    child: const Icon(
                                                      Icons.delete_outline,
                                                      size: 22,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}