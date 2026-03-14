import 'package:ecommerceapp/enums/order_status.dart';
import 'package:ecommerceapp/views/profile_screen/my_orders/order_class.dart';
import 'package:flutter/material.dart';
 

 
final List<OrderItem> sampleOrders = [
  OrderItem(
    orderId: 'ORD-100421',
    productName: 'Nike Air Max 270',
    productImage: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    quantity: 2,
    totalPrice: 299.98,
    status: OrderStatus.active,
    orderDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
  OrderItem(
    orderId: 'ORD-100398',
    productName: 'Sony WH-1000XM5',
    productImage: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
    quantity: 1,
    totalPrice: 349.99,
    status: OrderStatus.active,
    orderDate: DateTime.now().subtract(const Duration(days: 3)),
  ),
  OrderItem(
    orderId: 'ORD-100374',
    productName: 'Apple Watch Series 9',
    productImage: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400',
    quantity: 1,
    totalPrice: 399.00,
    status: OrderStatus.completed,
    orderDate: DateTime.now().subtract(const Duration(days: 12)),
  ),
  OrderItem(
    orderId: 'ORD-100360',
    productName: 'Leather Crossbody Bag',
    productImage: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400',
    quantity: 1,
    totalPrice: 89.95,
    status: OrderStatus.completed,
    orderDate: DateTime.now().subtract(const Duration(days: 20)),
  ),
  OrderItem(
    orderId: 'ORD-100341',
    productName: 'Mechanical Keyboard',
    productImage: 'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=400',
    quantity: 1,
    totalPrice: 159.00,
    status: OrderStatus.completed,
    orderDate: DateTime.now().subtract(const Duration(days: 30)),
  ),
  OrderItem(
    orderId: 'ORD-100319',
    productName: 'Adidas Running Shorts',
    productImage: 'https://images.unsplash.com/photo-1591195853828-11db59a44f43?w=400',
    quantity: 3,
    totalPrice: 89.97,
    status: OrderStatus.cancelled,
    orderDate: DateTime.now().subtract(const Duration(days: 8)),
  ),
  OrderItem(
    orderId: 'ORD-100305',
    productName: 'Wireless Earbuds Pro',
    productImage: 'https://images.unsplash.com/photo-1572536147248-ac59a8abfa4b?w=400',
    quantity: 1,
    totalPrice: 129.99,
    status: OrderStatus.cancelled,
    orderDate: DateTime.now().subtract(const Duration(days: 15)),
  ),
];
 
 
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: _buildAppBar(context),
        body: TabBarView(
          children: [
            _OrderList(status: OrderStatus.active),
            _OrderList(status: OrderStatus.completed),
            _OrderList(status: OrderStatus.cancelled),
          ],
        ),
      ),
    );
  }
 
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'My Orders',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Tab Bar
              const TabBar(
                padding: EdgeInsets.symmetric(horizontal: 16),
                labelColor: Color(0xFF4F46E5),
                unselectedLabelColor: Color(0xFF9CA3AF),
                labelStyle: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Color(0xFF4F46E5),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
 
class _OrderList extends StatelessWidget {
  final OrderStatus status;
 
  const _OrderList({required this.status});
 
  @override
  Widget build(BuildContext context) {
    final orders = sampleOrders.where((o) => o.status == status).toList();
 
    if (orders.isEmpty) {
      return _buildEmptyState(status);
    }
 
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OrderCard(order: orders[index]),
        );
      },
    );
  }
 
  Widget _buildEmptyState(OrderStatus status) {
    final Map<OrderStatus, Map<String, dynamic>> config = {
      OrderStatus.active: {
        'icon': Icons.local_shipping_outlined,
        'title': 'No Active Orders',
        'subtitle': 'You have no orders in progress right now.',
        'color': const Color(0xFF4F46E5),
      },
      OrderStatus.completed: {
        'icon': Icons.check_circle_outline_rounded,
        'title': 'No Completed Orders',
        'subtitle': 'Your completed orders will show up here.',
        'color': const Color(0xFF10B981),
      },
      OrderStatus.cancelled: {
        'icon': Icons.cancel_outlined,
        'title': 'No Cancelled Orders',
        'subtitle': 'You have not cancelled any orders.',
        'color': const Color(0xFFEF4444),
      },
    };
 
    final cfg = config[status]!;
 
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (cfg['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              cfg['icon'] as IconData,
              size: 38,
              color: cfg['color'] as Color,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            cfg['title'] as String,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cfg['subtitle'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
 
 
class _OrderCard extends StatelessWidget {
  final OrderItem order;
 
  const _OrderCard({required this.order});
 
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ── Top row: image + info + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    order.productImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFF5F6FA),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFD1D5DB),
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
 
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              order.productName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Order ID
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.orderId,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Qty + Price
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${order.quantity} ${order.quantity == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '\$${order.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
 
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 12),
 
            // ── Bottom row: date + View Details button
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(order.orderDate),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _ViewDetailsButton(order: order),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
 
 
class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
 
  const _StatusBadge({required this.status});
 
  @override
  Widget build(BuildContext context) {
    final Map<OrderStatus, Map<String, dynamic>> config = {
      OrderStatus.active: {
        'label': 'Active',
        'color': const Color(0xFF4F46E5),
        'bg': const Color(0xFFEEF2FF),
        'dot': const Color(0xFF4F46E5),
      },
      OrderStatus.completed: {
        'label': 'Completed',
        'color': const Color(0xFF059669),
        'bg': const Color(0xFFECFDF5),
        'dot': const Color(0xFF10B981),
      },
      OrderStatus.cancelled: {
        'label': 'Cancelled',
        'color': const Color(0xFFDC2626),
        'bg': const Color(0xFFFEF2F2),
        'dot': const Color(0xFFEF4444),
      },
    };
 
    final cfg = config[status]!;
 
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cfg['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: cfg['dot'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            cfg['label'] as String,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: cfg['color'] as Color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
 
 
class _ViewDetailsButton extends StatelessWidget {
  final OrderItem order;
 
  const _ViewDetailsButton({required this.order});
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to order detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing details for ${order.orderId}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'View Details',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              size: 13,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}