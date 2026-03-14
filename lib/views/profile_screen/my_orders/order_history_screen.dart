import 'package:ecommerceapp/enums/order_status.dart';
import 'package:ecommerceapp/models/order_model.dart';
import 'package:ecommerceapp/view_model/order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 

 

 
 
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
 
 @override
  Widget build(BuildContext context) {
     Future.microtask(() =>
        context.read<OrderViewModel>().fetchOrders());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: _buildAppBar(context),
        body: Consumer<OrderViewModel>(
          builder: (context, orderVM, _) {

            if (orderVM.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4F46E5),
                ),
              );
            }

            if (orderVM.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Color(0xFFEF4444)),
                    const SizedBox(height: 12),
                    Text(
                      'Something went wrong',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      orderVM.error!,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF9CA3AF)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => orderVM.fetchOrders(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
  children: [
    _OrderList(orders: orderVM.activeOrders,    status: OrderStatus.active),
    _OrderList(orders: orderVM.completedOrders, status: OrderStatus.completed),
    _OrderList(orders: orderVM.cancelledOrders, status: OrderStatus.cancelled),
  ],
);
          },
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
  final List<OrderModel> orders; 
  final OrderStatus status; 
 
  const _OrderList({required this.orders, required this.status,  });
 
   @override
  Widget build(BuildContext context) {
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
    final OrderModel order;               

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: firstItem != null
                      ? Image.network(
                          firstItem.productPic,
                          width: 80, height: 80, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imageFallback(),
                        )
                      : _imageFallback(),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                            
                              order.items.length > 1
                                  ? '${firstItem?.productName ?? ''} +${order.items.length - 1} more'
                                  : firstItem?.productName ?? '',
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
                          _StatusBadge(status: _parseStatus(order.status)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 13, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(order.orderId,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag_outlined,
                              size: 13, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                       Text(
  () {
    final totalQty = order.items.fold<int>(
      0, (sum, item) => sum + item.quantity,
    );
    return '$totalQty ${totalQty == 1 ? 'item' : 'items'}';
  }(),
  style: const TextStyle(
    fontSize: 12.5,
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w500,
  ),
),
                          const SizedBox(width: 10),
                          Text(
                            '\$${order.totalAmount}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4F46E5)),
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

            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 5),
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500),
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
   Widget _imageFallback() => Container(
        width: 80, height: 80,
        color: const Color(0xFFF5F6FA),
        child: const Icon(Icons.image_outlined,
            color: Color(0xFFD1D5DB), size: 30),
      );
        OrderStatus _parseStatus(String status) {
    switch (status) {
      case 'completed': return OrderStatus.completed;
      case 'cancelled': return OrderStatus.cancelled;
      default:          return OrderStatus.active;
    }
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
final OrderModel order; 
 
  const _ViewDetailsButton({required this.order});
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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