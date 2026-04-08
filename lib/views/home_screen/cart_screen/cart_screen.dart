import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/views/detail_screen/check_out_screeen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:provider/provider.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartBox = context.read<AuthViewModel>().getCartBox();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.background(context),
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: cartBox.listenable(),
        builder: (context, Box<CartModel> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

      
          int totalPrice = 0;
          for (var i = 0; i < box.length; i++) {
            final item = box.getAt(i)!;
            totalPrice += item.productPrice * item.quantity;
          }

          return Column(
            children: [
            
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.background(context),
                child: Text(
                  '${box.length} ${box.length == 1 ? 'Item' : 'Items'} in Cart',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              
              Expanded(
                child: Container(
                  color: AppColors.background(context),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final item = box.getAt(index)!;
                  
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:AppColors.cardBackground(context),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade100,
                                  child: Image.network(
                                    item.productImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image_outlined,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style:  TextStyle(
                                        color: AppColors.textPrimary(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.productCategory,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary(context),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$ ${item.productPrice}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                   
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.border(context),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                           
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    if (item.quantity > 1) {
                                                      item.quantity -= 1;
                                                      item.save();
                                                    } else {
                                                      box.deleteAt(index);
                                                    }
                                                  },
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    child: Icon(
                                                      item.quantity > 1 
                                                          ? Icons.remove 
                                                          : Icons.delete_outline,
                                                      size: 20,
                                                      color: item.quantity > 1
                                                          ? Color.fromARGB(255, 34, 99, 230) 
                                                          : AppColors.iconAdaptive(context)
                                                    ),
                                                  ),
                                                ),
                                              ),
                                         
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    if (item.quantity < item.stock) {
                                                      item.quantity += 1;
                                                      item.save();
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: const Text('Maximum stock reached'),
                                                          backgroundColor: Colors.orange,
                                                          behavior: SnackBarBehavior.floating,
                                                          margin: const EdgeInsets.all(16),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 20,
                                                      color: item.quantity < item.stock
                                                          ? const Color.fromARGB(255, 34, 99, 230)
                                                          : AppColors.iconAdaptive(context),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                  
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                           
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Remove Item'),
                                                  content: const Text(
                                                    'Are you sure you want to remove this item from cart?',
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        box.deleteAt(index);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        'Remove',
                                                        style: TextStyle(color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(10),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              child:  Icon(
                                                Icons.delete_outline,
                                                color: AppColors.iconAdaptive(context),
                                                size: 22,
                                              ),
                                            ),
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
                      );
                    },
                  ),
                ),
              ),
              
        
              Container(
                decoration: BoxDecoration(
                  color:AppColors.cardBackground(context),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                       
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                            Text(
                              '\$ $totalPrice',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Divider(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: AppColors.primaryEnd,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$ $totalPrice',
                              style:  TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryEnd
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient, 
    borderRadius: BorderRadius.circular(14),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        final cartItems = cartBox.values.toList();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CheckOutScreen(cartItems: cartItems),
          ),
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Center(
          child: Text(
            'Proceed to Checkout',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  ),
),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}