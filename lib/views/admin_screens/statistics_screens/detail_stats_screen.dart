import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:ecommerceapp/view_model/stats_view_model.dart';

class DetailedSalesScreen extends StatelessWidget {
  const DetailedSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsViewModel>().fetchStats();
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryLight),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Sales Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryLight),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryLight),
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
                    ElevatedButton(
                      onPressed: () => statsVM.refreshStats(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final dailySales = _groupSalesByDate(statsVM);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Sales Overview',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: FadeInLeft(
                        duration: const Duration(milliseconds: 800),
                        child: _SummaryCard(
                          title: 'Total Days',
                          value: dailySales.length.toString(),
                          icon: Icons.calendar_today,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FadeInRight(
                        duration: const Duration(milliseconds: 800),
                        child: _SummaryCard(
                          title: 'Avg/Day',
                          value: _calculateAverageSalesPerDay(dailySales),
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Sales Trend (Last 7 Days)',
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
                  child: _WeeklySalesChart(dailySales: dailySales),
                ),
                const SizedBox(height: 24),

                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Breakdown',
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${dailySales.length} days',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                ...dailySales.entries.map((entry) {
                  final index = dailySales.keys.toList().indexOf(entry.key);
                  return _DailySalesCard(
                    date: entry.key,
                    sales: entry.value,
                    index: index,
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupSalesByDate(
    StatsViewModel statsVM,
  ) {
    final Map<DateTime, List<Map<String, dynamic>>> grouped = {};

    for (var order in statsVM.recentOrders) {
      DateTime orderDate;

      if (order['timestamp'] != null) {
        if (order['timestamp'] is DateTime) {
          orderDate = order['timestamp'];
        } else if (order['timestamp'].runtimeType.toString() == 'Timestamp') {
          orderDate = order['timestamp'].toDate();
        } else {
          try {
            orderDate = DateTime.parse(order['timestamp'].toString());
          } catch (e) {
            orderDate = DateTime.now();
          }
        }
      } else {
        orderDate = DateTime.now();
      }

      final dateOnly = DateTime(orderDate.year, orderDate.month, orderDate.day);

      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(order);
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(sortedEntries);
  }

  String _calculateAverageSalesPerDay(
    Map<DateTime, List<Map<String, dynamic>>> dailySales,
  ) {
    if (dailySales.isEmpty) return '0';

    double totalRevenue = 0;
    for (var sales in dailySales.values) {
      for (var sale in sales) {
        totalRevenue += (sale['total'] ?? 0);
      }
    }

    final average = totalRevenue / dailySales.length;
    return '\$${average.toStringAsFixed(0)}';
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklySalesChart extends StatelessWidget {
  final Map<DateTime, List<Map<String, dynamic>>> dailySales;

  const _WeeklySalesChart({required this.dailySales});

  @override
  Widget build(BuildContext context) {
    final last7Days = _getLast7DaysData();

    if (last7Days.isEmpty) {
      return Container(
        height: 250,
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
        child: Center(
          child: Text(
            'No sales data available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      height: 250,
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
      child: LineChart(
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= last7Days.length) return const Text('');
                  final date = last7Days.keys.elementAt(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('E').format(date),
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
                    '\$${value.toInt()}',
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
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(last7Days),
              isCurved: true,
              gradient: LinearGradient(
                colors: [Colors.orange[300]!, Colors.orange[600]!],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.orange,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.3),
                    Colors.orange.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, double> _getLast7DaysData() {
    final Map<DateTime, double> last7Days = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      double dayTotal = 0;

      if (dailySales.containsKey(date)) {
        for (var sale in dailySales[date]!) {
          dayTotal += (sale['total'] ?? 0);
        }
      }

      last7Days[date] = dayTotal;
    }

    return last7Days;
  }

  List<FlSpot> _generateSpots(Map<DateTime, double> data) {
    final spots = <FlSpot>[];
    int index = 0;

    for (var entry in data.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value));
      index++;
    }

    return spots;
  }
}

class _DailySalesCard extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> sales;
  final int index;

  const _DailySalesCard({
    required this.date,
    required this.sales,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final totalRevenue = _calculateDayRevenue();
    final totalItems = _calculateTotalItems();

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: index * 100),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMM').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[800],
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              DateFormat('EEEE, MMMM d, y').format(date),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$totalItems items • \$$totalRevenue total',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
            trailing: Chip(
              label: Text(
                '${sales.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: Colors.orange.withOpacity(0.1),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            children: [
              const Divider(height: 1),
              const SizedBox(height: 12),
              ...sales.map((sale) => _ProductSaleItem(sale: sale)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDayRevenue() {
    double total = 0;
    for (var sale in sales) {
      total += (sale['total'] ?? 0);
    }
    return total.toStringAsFixed(2);
  }

  int _calculateTotalItems() {
    int total = 0;
    for (var sale in sales) {
      total += (sale['quantity'] ?? 0) as int;
    }
    return total;
  }
}

class _ProductSaleItem extends StatelessWidget {
  final Map<String, dynamic> sale;

  const _ProductSaleItem({required this.sale});

  String _formatTimestamp(dynamic timestamp) {
    try {
      DateTime dateTime;

      if (timestamp == null) {
        return 'N/A';
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp.runtimeType.toString() == 'Timestamp') {
        dateTime = timestamp.toDate();
      } else {
        dateTime = DateTime.parse(timestamp.toString());
      }

      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              sale['productPic'] ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_outlined, color: Colors.grey[400]),
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
                  sale['productName'] ?? 'Unknown Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  sale['userName'] ?? 'Unknown User',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Qty: ${sale['quantity']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(sale['timestamp']),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
                '\$${sale['total']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Paid',
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
    );
  }
}
