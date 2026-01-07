import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:ecommerceapp/models/product_review_model.dart';
import 'package:ecommerceapp/services/deep_link_services.dart';
import 'package:ecommerceapp/services/stripe_service/stripe_service.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/detail_view_model.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/views/detail_screen/check_out_screeen.dart';
import 'package:ecommerceapp/views/detail_screen/detailed_review_screen.dart';
import 'package:ecommerceapp/views/detail_screen/product_reviews.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatelessWidget {

    final List<String> productImageUrls; 
  final String productName;
  final String categoryName;
  final int price;
  final int discount;
  final String description;
  String productId;

  DetailScreen({
    required this.productImageUrls, 
    required this.productName,
    required this.categoryName,
    required this.price,
    required this.discount,
    required this.description,
    required this.productId
  });


final productLink =
      'https://ecommerce-app-sand-eight.vercel.app/product/123';

int getDiscountedPrice() {
  if (discount <= 0) return price;
  return price - ((price * discount) ~/ 100);
}


  @override
  Widget build(BuildContext context) {
    final sizeList = ['S', 'M', 'L', 'XL'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions:  [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child:  IconButton(
    icon:  Icon(Icons.share_outlined),
    onPressed: () async{
      final params = ShareParams(
      text: 'Check this product:\n$productLink',
    );

    await SharePlus.instance.share(params);
    },
  )
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
Container(
  height: 270,
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Stack(
    children: [
      Center(
        child: Image.network(
          productImageUrls.isNotEmpty 
            ? productImageUrls[0] 
            : 'https://via.placeholder.com/260', // Fallback image
          height: 260,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        top: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_border,
            size: 20,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 16),

/// Thumbnails
SizedBox(
  height: 70,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: productImageUrls.length,
    separatorBuilder: (_, __) => const SizedBox(width: 12),
    itemBuilder: (context, index) {
      return Container(
        width: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: index == 0
                ? Colors.orange
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            productImageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.image,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      );
    },
  ),
),            const SizedBox(height: 20),

            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          categoryName,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    ),

   Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    if (discount > 0)
      Text(
        '\$${getDiscountedPrice()}',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          decoration: TextDecoration.lineThrough,
        ),
      ),

    Text(
      '\$${price.toString()}',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    if (discount > 0)
      Text(
        '$discount% OFF',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
  ],
),

  ],
),


            const SizedBox(height: 20),

            /// Size Selector
            const Text(
              'Select Size',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: sizeList.map((size) {
                final isSelected = size == 'L';
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),


            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
             Text(
              description,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
Consumer<ProductReviewViewModel>(
  builder: (context, vm, _) {
    final avgRating = vm.reviews.isEmpty 
        ? 0.0 
        : vm.reviews.map((r) => r.rating).reduce((a, b) => a + b) / vm.reviews.length;
    
    // Calculate rating distribution
    Map<String, int> ratingLabels = {
      'Excellent': 0,
      'Good': 0,
      'Average': 0,
      'Poor': 0,
    };
    
    for (var review in vm.reviews) {
      if (review.rating == 5) ratingLabels['Excellent'] = ratingLabels['Excellent']! + 1;
      else if (review.rating == 4) ratingLabels['Good'] = ratingLabels['Good']! + 1;
      else if (review.rating == 3) ratingLabels['Average'] = ratingLabels['Average']! + 1;
      else ratingLabels['Poor'] = ratingLabels['Poor']! + 1;
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductReviewsScreen(
              productId: productId,
              productName: productName,
              productImage: productImageUrls.isNotEmpty 
                  ? productImageUrls[0] 
                  : 'https://via.placeholder.com/260',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Rating and Bars Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Overall Rating
                Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 16,
                          color: i < avgRating.round()
                              ? Colors.amber
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.reviews.length} reviews',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 20),
                
                // Right: Rating Bars
                if (vm.reviews.isNotEmpty)
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar('Excellent', ratingLabels['Excellent']!, vm.reviews.length, Colors.green),
                        const SizedBox(height: 6),
                        _buildRatingBar('Good', ratingLabels['Good']!, vm.reviews.length, Colors.teal),
                        const SizedBox(height: 6),
                        _buildRatingBar('Average', ratingLabels['Average']!, vm.reviews.length, Colors.orange),
                        const SizedBox(height: 6),
                        _buildRatingBar('Poor', ratingLabels['Poor']!, vm.reviews.length, Colors.red),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Single Review Preview
            if (vm.reviews.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.green.shade100,
                      backgroundImage: NetworkImage(
                        'https://ui-avatars.com/api/?name=${vm.reviews.first.userName}&background=random',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                vm.reviews.first.userName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 12,
                                    color: i < vm.reviews.first.rating
                                        ? Colors.amber
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vm.reviews.first.comment.isNotEmpty 
                                ? vm.reviews.first.comment 
                                : 'Great product! Highly recommended.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Write Review Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please login to write a review')),
                    );
                    return;
                  }
                  
                  final userReview = vm.reviews.firstWhereOrNull(
                    (r) => r.userId == user.uid,
                  );
                  
                  showDialog(
                    context: context,
                    builder: (_) => ReviewDialog(
                      productId: productId,
                      existingReview: userReview,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Write a review',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
),


            const SizedBox(height: 100),
            
        
            
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: (){
                      addToCart(context);
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color.fromARGB(255, 179, 177, 177)),
                  ),
                  child:  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: const Color.fromARGB(255, 179, 177, 177)
                                      
                            ),
                          ),
                          child: Icon(Icons.add,color: const Color.fromARGB(255, 179, 177, 177))),
                        Text(
                          'Add To Cart',
                          style: TextStyle(  fontWeight: FontWeight.w600, fontSize: 18,color: const Color.fromARGB(255, 179, 177, 177)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(

                
             onTap: () {
  final singleItem = CartModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    productName: productName,
    productCategory: categoryName,
    productPrice: getDiscountedPrice(),
    productImage: productImageUrls.isNotEmpty 
        ? productImageUrls.first 
        : 'https://st5.depositphotos.com/90358332/74974/v/450/depositphotos_749740000-stock-illustration-photo-thumbnail-graphic-element-found.jpg',
    quantity: 1,
    stock: 10,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CheckOutScreen(
        singleItem: singleItem,
      //  productPrice: price,
      ),
    ),
  );

   
                     
                },
                child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(14),
                                 
                ),
                child: Center(
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                         
                            ),
                            child: Icon(Icons.shopping_cart_checkout_rounded,size: 23,color: Colors.white)
                            ),
                          Text(
                            'Buy Now',
                            style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                ),
                                ),
              )
            ),
          ],
        ),
      ),
    );
  }



void addToCart(BuildContext context, {int stock = 10}) async {
  try {
    final cartBox = context.read<AuthViewModel>().getCartBox();
    
    // Find existing item
    int? existingIndex;
    for (var i = 0; i < cartBox.length; i++) {
      if (cartBox.getAt(i)!.productName == productName) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != null) {
      final existingItem = cartBox.getAt(existingIndex)!;
      if (existingItem.quantity < stock) {
        existingItem.quantity += 1;
        await existingItem.save();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added another item to cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum stock reached')),
        );
      }
    } else {
   
      final cartItem = CartModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: productName,
        productCategory: categoryName,
        productPrice: price,
        productImage: productImageUrls.isNotEmpty 
            ? productImageUrls.first 
            : 'https://via.placeholder.com/260',
        quantity: 1,
        stock: stock, 
      );
      
      await cartBox.add(cartItem);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    }
  } catch (e) {
    print('Error adding to cart: $e'); // Debug print
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
Widget _buildRatingBar(String label, int count, int total, Color color) {
  final percentage = total == 0 ? 0.0 : count / total;
  
  return Row(
    children: [
      SizedBox(
        width: 60,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

}
