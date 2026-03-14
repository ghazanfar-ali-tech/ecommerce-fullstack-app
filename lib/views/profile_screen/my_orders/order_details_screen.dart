import 'package:ecommerceapp/models/cart_item_model.dart';
import 'package:ecommerceapp/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _StatusTimeline(status: order.status),
                  const SizedBox(height: 20),
                  _buildOrderIdCard(context),
                  const SizedBox(height: 16),
                  _SectionLabel(label: 'Items Ordered'),
                  const SizedBox(height: 10),
                  ...order.items.map((item) => _ItemRow(item: item)).toList(),
                  const SizedBox(height: 16),
                  _SectionLabel(label: 'Shipping Address'),
                  const SizedBox(height: 10),
                  _AddressCard(address: order.shippingAddress),
                  const SizedBox(height: 16),
                  _SectionLabel(label: 'Price Breakdown'),
                  const SizedBox(height: 10),
                  _PriceSummaryCard(order: order),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: const Color(0xFF4F46E5),
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
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Order Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }


  Widget _buildOrderIdCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded,
              color: Color(0xFF4F46E5), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order ID',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order.orderId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F46E5),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: order.orderId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order ID copied'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF4F46E5),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.copy_rounded,
                  size: 15, color: Color(0xFF4F46E5)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute $period';
  }
}


class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Order Placed', 'icon': Icons.check_circle_rounded},
      {'label': 'Processing',   'icon': Icons.inventory_2_rounded},
      {'label': 'Shipped',      'icon': Icons.local_shipping_rounded},
      {'label': 'Delivered',    'icon': Icons.home_rounded},
    ];

    final activeStep = status == 'active'
        ? 2
        : status == 'completed'
            ? 4
            : 0; 

    final isCancelled = status == 'cancelled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              if (isCancelled)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Cancelled',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
             
                final stepIndex = (i ~/ 2) + 1;
                final isDone = !isCancelled && stepIndex < activeStep;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isDone
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFE5E7EB),
                  ),
                );
              }

              final stepIndex = i ~/ 2;
              final isDone = !isCancelled && stepIndex < activeStep;
              final isCurrent =
                  !isCancelled && stepIndex == activeStep - 1;

              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCancelled
                          ? const Color(0xFFF3F4F6)
                          : isDone
                              ? const Color(0xFF4F46E5)
                              : isCurrent
                                  ? const Color(0xFFEEF2FF)
                                  : const Color(0xFFF3F4F6),
                      border: isCurrent && !isCancelled
                          ? Border.all(
                              color: const Color(0xFF4F46E5), width: 2)
                          : null,
                    ),
                    child: Icon(
                      steps[stepIndex]['icon'] as IconData,
                      size: 17,
                      color: isCancelled
                          ? const Color(0xFFD1D5DB)
                          : isDone
                              ? Colors.white
                              : isCurrent
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFFD1D5DB),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[stepIndex]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCancelled
                          ? const Color(0xFFD1D5DB)
                          : isDone || isCurrent
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
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
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
                color: const Color(0xFFF5F6FA),
                child: const Icon(Icons.image_outlined,
                    color: Color(0xFFD1D5DB), size: 24),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Qty: ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(item.price * item.quantity)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${item.price} each',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: Color(0xFF4F46E5), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              address,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF374151),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
              valueColor: const Color(0xFF10B981),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '\$${order.totalAmount}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4F46E5),
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
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}