import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/views/admin_screens/dash_borad_screens/empty_screen.dart';
import 'package:ecommerceapp/views/admin_screens/statistics_screens/animated_sales_button.dart';
import 'package:ecommerceapp/views/admin_screens/statistics_screens/detail_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ecommerceapp/view_model/stats_view_model.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsViewModel>().fetchStats();
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // centerTitle: true,
        backgroundColor: const Color(0xFF3B82F6),
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),

        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primaryLight),
            onPressed: () {
              context.read<StatsViewModel>().refreshStats();
            },
          ),
        ],
      ),
      body: Consumer<StatsViewModel>(
        builder: (context, statsVM, _) {
          if (statsVM.loading) {
            return Center(
              child: SpinPerfect(
                infinite: true,
                duration: const Duration(milliseconds: 1000),
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 64,
                  color: Colors.orange,
                ),
              ),
            );
          }

          if (statsVM.error != null) {
            return Center(
              child: FadeIn(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Bounce(
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      statsVM.error!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Pulse(
                      infinite: true,
                      child: ElevatedButton(
                        onPressed: () => statsVM.refreshStats(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Balance Overview',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColors.primaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: FadeInLeft(
                        duration: const Duration(milliseconds: 800),
                        child: _StatCard(
                          title: 'New Orders',
                          value: statsVM.totalSales,
                          icon: Icons.shopping_bag_outlined,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FadeInRight(
                        duration: const Duration(milliseconds: 800),
                        child: _StatCard(
                          title: 'Sales',
                          value: statsVM.totalProducts,
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ZoomIn(
                  duration: const Duration(milliseconds: 1000),
                  child: _StatCard(
                    title: 'Revenue',
                    value: statsVM.totalRevenue,
                    icon: Icons.attach_money,
                    color: Colors.orange,
                    isLarge: true,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: FadeInLeft(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 200),
                        child: _StatCard(
                          title: 'Customers',
                          value: statsVM.uniqueUsers,
                          icon: Icons.people_outline,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FadeInRight(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 200),
                        child: _StatCard(
                          title: 'Products',
                          value: statsVM.uniqueProductsSold,
                          icon: Icons.inventory_2_outlined,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Top Categories',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 200),
                  child: _CategoryPieChart(statsVM: statsVM),
                ),
                const SizedBox(height: 24),

                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Top Selling Products',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 200),
                  child: _TopProductsBarChart(statsVM: statsVM),
                ),
                const SizedBox(height: 24),

                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _RecentOrdersList(statsVM: statsVM),
                const SizedBox(height: 24),

                AnimatedDetailedSalesButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailedSalesScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final num value;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: widget.isLarge ? 28 : 24,
      fontWeight: FontWeight.bold,
      color: widget.color,
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(widget.isLarge ? 20 : 16),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? widget.color.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _isPressed ? 15 : 10,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElasticIn(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 24),
                  ),
                ),
                if (widget.isLarge)
                  Bounce(
                    infinite: true,
                    duration: const Duration(seconds: 2),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedNumber(
              value: widget.value,
              style: textStyle,
              isLarge: widget.isLarge,
              prefix: widget.title == 'Revenue' ? '\$' : null,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedNumber extends ImplicitlyAnimatedWidget {
  final num value;
  final TextStyle style;
  final bool isLarge;
  final String? prefix;

  const AnimatedNumber({
    required this.value,
    required this.style,
    this.isLarge = false,
    this.prefix,
    super.key,
    super.curve = Curves.easeInOut,
    super.duration = const Duration(milliseconds: 1200),
  });

  @override
  ImplicitlyAnimatedWidgetState<AnimatedNumber> createState() =>
      _AnimatedNumberState();
}

class _AnimatedNumberState extends AnimatedWidgetBaseState<AnimatedNumber> {
  Tween<num>? _valueTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _valueTween =
        visitor(
              _valueTween,
              widget.value,
              (dynamic value) => Tween<num>(begin: value as num),
            )
            as Tween<num>?;
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = _valueTween?.evaluate(animation) ?? widget.value;
    final displayValue = widget.isLarge && widget.value is double
        ? currentValue.toStringAsFixed(2)
        : currentValue.toInt().toString();
    return Text('${widget.prefix ?? ''}$displayValue', style: widget.style);
  }
}

class _CategoryPieChart extends StatelessWidget {
  final StatsViewModel statsVM;

  const _CategoryPieChart({required this.statsVM});

  @override
  Widget build(BuildContext context) {
    final topCategories = statsVM.getTopCategories(limit: 5);

    if (topCategories.isEmpty) {
      return EmptyChart(message: 'No category data available');
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              key: ValueKey(statsVM.touchedPieIndex),
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      statsVM.setTouchedPieIndex(-1);
                      return;
                    }
                    statsVM.setTouchedPieIndex(
                      pieTouchResponse.touchedSection!.touchedSectionIndex,
                    );
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 45,
                sections: _generatePieSections(
                  topCategories,
                  statsVM.touchedPieIndex,
                ),
              ),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _CategoryLegend(categories: topCategories)),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(
    List<MapEntry<String, int>> categories,
    int touchedIndex,
  ) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.pink,
    ];

    return List.generate(categories.length, (index) {
      final category = categories[index];
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 90.0 : 60.0;
      final shadows = isTouched
          ? [const Shadow(color: Colors.black, blurRadius: 4)]
          : null;

      return PieChartSectionData(
        value: category.value.toDouble(),
        title: '${category.value}',
        color: colors[index % colors.length],
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
}

class _CategoryLegend extends StatelessWidget {
  final List<MapEntry<String, int>> categories;

  const _CategoryLegend({required this.categories});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.pink,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        categories.length,
        (index) => FadeInRight(
          duration: Duration(milliseconds: 600 + (index * 100)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categories[index].key,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopProductsBarChart extends StatelessWidget {
  final StatsViewModel statsVM;

  const _TopProductsBarChart({required this.statsVM});

  @override
  Widget build(BuildContext context) {
    final topProducts = statsVM.getTopSellingProducts(limit: 5);

    if (topProducts.isEmpty) {
      return EmptyChart(message: 'No product sales data available');
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        key: ValueKey(statsVM.touchedBarIndex),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.elasticOut,
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: topProducts.first.value.toDouble() * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.spot == null) {
                statsVM.setTouchedBarIndex(-1);
                return;
              }
              statsVM.setTouchedBarIndex(response.spot!.touchedBarGroupIndex);
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.grey[800]!,

              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final product = topProducts[groupIndex];
                return BarTooltipItem(
                  '${product.key}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toInt()} sold',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= topProducts.length)
                    return const Text('');
                  final productName = topProducts[value.toInt()].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      productName.length > 10
                          ? '${productName.substring(0, 10)}...'
                          : productName,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: _generateBarGroups(topProducts, statsVM.touchedBarIndex),
        ),
        swapAnimationDuration: const Duration(milliseconds: 1000),
        swapAnimationCurve: Curves.easeInOutCubic,
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(
    List<MapEntry<String, int>> topProducts,
    int touchedIndex,
  ) {
    return List.generate(
      topProducts.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: topProducts[index].value.toDouble(),
            gradient: LinearGradient(
              colors: index == touchedIndex
                  ? [Colors.orange[400]!, Colors.orange[800]!]
                  : [Colors.orange[300]!, Colors.orange[600]!],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: index == touchedIndex ? 28 : 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: topProducts.first.value.toDouble() * 1.2,
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrdersList extends StatelessWidget {
  final StatsViewModel statsVM;

  const _RecentOrdersList({required this.statsVM});

  @override
  Widget build(BuildContext context) {
    if (statsVM.recentOrders.isEmpty) {
      return EmptyChart(message: 'No recent orders');
    }

    return Column(
      children: statsVM.recentOrders.asMap().entries.map((entry) {
        final index = entry.key;
        final order = entry.value;
        return FadeInUp(
          duration: Duration(milliseconds: 600),
          delay: Duration(milliseconds: index * 100),
          child: SlideInLeft(
            duration: Duration(milliseconds: 600),
            delay: Duration(milliseconds: index * 100),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order['productPic'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['productName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['userName'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qty: ${order['quantity']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flash(
                        delay: Duration(milliseconds: index * 100 + 600),
                        child: Text(
                          '\$${order['total']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
