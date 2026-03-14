import 'package:ecommerceapp/models/cart_item_model.dart';
import 'package:ecommerceapp/models/order_model.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  

  const OrderDetailScreen({super.key, required this.order});
String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute $period';
  }
  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          _OrderAppBar(order: order),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
        _formatDate(order.createdAt),
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w500,
        ),
      ),

      const SizedBox(height: 16),
                _StatusTimeline(status: order.status),
                const SizedBox(height: 16),
                _OrderIdCard(orderId: order.orderId),
                const SizedBox(height: 20),
                _SectionLabel(label: 'Items Ordered'),
                const SizedBox(height: 10),
                ...order.items.map((item) => _ItemRow(item: item)),
                const SizedBox(height: 16),
                _SectionLabel(label: 'Shipping Address'),
                const SizedBox(height: 10),
                _AddressCard(address: order.shippingAddress),
                const SizedBox(height: 16),
                _SectionLabel(label: 'Price Breakdown'),
                const SizedBox(height: 10),
                _PriceSummaryCard(order: order),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderAppBar extends StatelessWidget {
  final OrderModel order;
  const _OrderAppBar({required this.order});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
      title: const Text(
        'Order Details',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }
}

class _OrderIdCard extends StatelessWidget {
  final String orderId;

  const _OrderIdCard({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: orderId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order ID copied'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.copy_rounded, size: 15, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}


class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  static const _steps = [
    {'label': 'Placed',     'icon': Icons.check_circle_rounded},
    {'label': 'Processing', 'icon': Icons.inventory_2_rounded},
    {'label': 'Shipped',    'icon': Icons.local_shipping_rounded},
    {'label': 'Delivered',  'icon': Icons.home_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final isCancelled = status == 'cancelled';
    final activeStep = isCancelled ? 0 : status == 'completed' ? 4 : 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const Spacer(),
              if (isCancelled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Cancelled',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final isFilled = !isCancelled && (i ~/ 2) + 1 < activeStep;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isFilled ? AppColors.primary : AppColors.border(context),
                  ),
                );
              }
              final stepIndex = i ~/ 2;
              return _StepDot(
                icon: _steps[stepIndex]['icon'] as IconData,
                label: _steps[stepIndex]['label'] as String,
                isDone: !isCancelled && stepIndex < activeStep,
                isCurrent: !isCancelled && stepIndex == activeStep - 1,
                isCancelled: isCancelled,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDone;
  final bool isCurrent;
  final bool isCancelled;

  const _StepDot({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.isCurrent,
    required this.isCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isCancelled
        ? Colors.grey.shade100
        : isDone
            ? AppColors.primary
            : isCurrent
                ? AppColors.primaryLight
                : Colors.grey.shade100;

    final iconColor = isCancelled
        ? Colors.grey.shade300
        : isDone
            ? Colors.white
            : isCurrent
                ? AppColors.primary
                : Colors.grey.shade300;

    final labelColor = isCancelled
        ? Colors.grey.shade300
        : isDone || isCurrent
            ? AppColors.primary
            : Colors.grey.shade400;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: isCurrent && !isCancelled
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(context),
        letterSpacing: -0.1,
      ),
    );
  }
}


class _ItemRow extends StatelessWidget {
  final CartItemModel item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.productPic,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: AppColors.background(context),
                child: Icon(Icons.image_outlined,
                    color: AppColors.border(context), size: 24),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                    letterSpacing: -0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.categoryName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Qty: ${item.quantity}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.price * item.quantity}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${item.price} each',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _AddressCard extends StatelessWidget {
  final String address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              address,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _PriceSummaryCard extends StatelessWidget {
  final OrderModel order;
  const _PriceSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Subtotal', value: '\$${order.subtotal}'),
          const SizedBox(height: 10),
          _PriceRow(label: 'Shipping', value: '\$${order.shipping}'),
          const SizedBox(height: 10),
          _PriceRow(label: 'Tax', value: '\$${order.tax}'),
          if (order.discount > 0) ...[
            const SizedBox(height: 10),
            _PriceRow(
              label: 'Discount',
              value: '-\$${order.discount}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.border(context)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                '\$${order.totalAmount}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}