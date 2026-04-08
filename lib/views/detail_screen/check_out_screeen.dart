import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:ecommerceapp/models/cart_item_model.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/resources/components/coupon_field.dart';
import 'package:ecommerceapp/services/stripe_service/stripe_service.dart';
import 'package:ecommerceapp/view_model/address_view_model.dart';
import 'package:ecommerceapp/view_model/coupon_view_model.dart';
import 'package:ecommerceapp/view_model/order_view_model.dart';
import 'package:ecommerceapp/view_model/stats_view_model.dart';
import 'package:ecommerceapp/views/detail_screen/safepay_screen.dart';
import 'package:ecommerceapp/views/profile_screen/address_screen/address_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class CheckOutScreen extends StatelessWidget {
  final List<CartModel> cartItems;

  CheckOutScreen({
    Key? key,
    List<CartModel>? cartItems,
    CartModel? singleItem,
  })  : cartItems = singleItem != null ? [singleItem] : (cartItems ?? []),
        super(key: key);

  int get subtotal {
    int sub = 0;
    for (var item in cartItems) {
      sub += item.productPrice * item.quantity;
    }
    return sub;
  }

  List<CartItemModel> get cartItemModels {
    return cartItems.map((cartModel) => CartItemModel(
      productName: cartModel.productName,
      productPic: cartModel.productImage,
      price: cartModel.productPrice,
      quantity: cartModel.quantity,  
      categoryName: cartModel.productCategory,
    )).toList();
  }

  final TextEditingController _couponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background(context),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: AppColors.iconAdaptive(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          "Checkout",
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CouponViewModel>(
        builder: (context, couponVM, _) {
          final totalAfterDiscount = (subtotal + 15 + 24) - couponVM.discount;

          return Column(
            children: [
              Expanded(
                child: Container(
                  color: AppColors.background(context),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          title: "Shipping Address",
                          icon: Icons.local_shipping_outlined,
                        ),
                        const SizedBox(height: 12),
                        Consumer<AddressViewModel>(
                          builder: (context, viewModel, _) {
                            if (viewModel.isLoading) {
                              return _LoadingCard();
                            }
                            final address = viewModel.checkoutAddress;
                            return _AddressCard(address: address);
                          },
                        ),
                        const SizedBox(height: 24),
                  
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SafepayScreen()));
                          },
                          child: Text("Safe pay"),
                        ),
                        _SectionHeader(
                          title: "Payment Method",
                          icon: Icons.payment_outlined,
                        ),
                        const SizedBox(height: 12),
                        _PaymentMethodCard(),
                        const SizedBox(height: 24),
                  
                        couponField(
                          controller: _couponController,
                          onApply: () {
                            couponVM.applyCoupon(
                                _couponController.text.trim(), context);
                          },
                        ),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: "Order Summary",
                          icon: Icons.receipt_long_outlined,
                        ),
                        const SizedBox(height: 12),
                        OrderSummaryCard(
                          subtotal: subtotal,
                          shipping: 15,
                          tax: 24,
                          discount: couponVM.discount,
                          totalAmount: totalAfterDiscount,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              _CheckoutBottomBar(
                totalAmount: totalAfterDiscount,
                cartItemModels: cartItemModels, 
                  subtotal: subtotal,  
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.iconAdaptive(context)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color:  AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final dynamic address;

  const _AddressCard({this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: address == null
            ? _EmptyAddressState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.pink,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Primary Address",
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => AddressScreen()));
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppColors.iconAdaptive(context),
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.border(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 12),
                  Text(
                    '${address.street}',
                    style: TextStyle(
                     color: AppColors.textSecondary(context),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address.city}, ${address.state} ${address.zip}',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.country,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.location_off_outlined,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          "No shipping address added",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => AddressScreen()));
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Add Address"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.pink,
            side: const BorderSide(color: Colors.pink),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                "assets/stripe.svg",
                height: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Stripe Payment",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Secure payment processing",
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.credit_score_rounded,
              color: Colors.green,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  final int subtotal;
  final int shipping;
  final int tax;
  final int discount;
  final int totalAmount;

  OrderSummaryCard({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _SummaryRow(label: "Subtotal", value: "\$$subtotal"),
          _SummaryRow(label: "Shipping", value: "\$$shipping"),
          _SummaryRow(label: "Tax", value: "\$$tax"),
          if (discount > 0)
            _SummaryRow(
              label: "Coupon Discount",
              value: "-\$$discount",
              color: Colors.green,
            ),
          const Divider(),
          _SummaryRow(
            label: "Total",
            value: "\$$totalAmount",
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppColors.primaryEnd : AppColors.primaryEnd,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: color ?? (isTotal ? AppColors.primaryEnd : AppColors.primaryEnd),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final int totalAmount;
  final List<CartItemModel> cartItemModels; 
  
 final int subtotal;  

  const _CheckoutBottomBar({
    required this.totalAmount,
     required this.subtotal, 
    required this.cartItemModels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$$totalAmount",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient, 
    borderRadius: BorderRadius.circular(12),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final statsVM = context.read<StatsViewModel>();
        final orderVM = context.read<OrderViewModel>();
        final couponVM = context.read<CouponViewModel>();
        final addressVM = context.read<AddressViewModel>();

        bool success = await StripeServices.instance.makePayment(
          amount: totalAmount,
          currency: 'usd',
          userName: "John Doe",
          statsViewModel: statsVM,
          cartItems: cartItemModels,
        );

        if (success) {
          await orderVM.placeOrder(
            items: cartItemModels,
            subtotal: subtotal,
            shipping: 15,
            tax: 24,
            discount: couponVM.discount,
            totalAmount: totalAmount,
            shippingAddress: addressVM.checkoutAddress != null
                ? '${addressVM.checkoutAddress!.name}, '
                  '${addressVM.checkoutAddress!.street}, '
                  '${addressVM.checkoutAddress!.city}, '
                  '${addressVM.checkoutAddress!.state} '
                  '${addressVM.checkoutAddress!.zip}, '
                  '${addressVM.checkoutAddress!.country}'
                : '',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase successful!')),
          );

          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment failed!')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        child: Row(
          children: const [
            Text(
              "Place Order",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 20, color: Colors.white),
          ],
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
  }
}