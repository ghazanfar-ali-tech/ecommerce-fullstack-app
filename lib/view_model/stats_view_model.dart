import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/cart_item_model.dart';
import 'package:flutter/foundation.dart';

class StatsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int totalSales = 0;
  int totalRevenue = 0;
  int totalProducts = 0;
  int uniqueUsers = 0;
  int uniqueProductsSold = 0;
  
  List<Map<String, dynamic>> recentOrders = [];
  Map<String, int> productSalesCount = {};
  Map<String, int> topSpenders = {};
  Map<String, int> categorySalesCount = {}; 
  
  bool loading = false;
  String? error;

  List<MapEntry<String, int>> getTopCategories({int limit = 5}) {
    var sorted = categorySalesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  Future<void> addSingleProductStats({
    required String productName,
    required String productPic,
    required int price,
    required String userName,
    required String categoryName
  }) async {
    try {
      await _firestore.collection("productStats").add({
        "productName": productName,
        "productPic": productPic,
        "price": price,
        "quantity": 1,
        "userName": userName,
        "categoryName": categoryName,
        "timestamp": FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to add single product stats: $e");
      }
      rethrow;
    }
  }

  Future<void> addCartStats({
    required List<CartItemModel> cartItems,
    required String userName,
  }) async {
    try {
    
      
      final batch = _firestore.batch();
      final statsCollection = _firestore.collection("productStats");
      
      int itemIndex = 0;
      for (var item in cartItems) {
        itemIndex++;
        print('  [$itemIndex/${cartItems.length}] Preparing: ${item.productName}');
        print('      - Quantity: ${item.quantity}');
        print('      - Price: \${item.price}');
        print('      - Category: ${item.categoryName}');
        
        final docRef = statsCollection.doc();
        batch.set(docRef, {
          "productName": item.productName,
          "productPic": item.productPic,
          "price": item.price,
          "quantity": item.quantity,  
          "userName": userName,
          "categoryName": item.categoryName ?? "Uncategorized",
          "timestamp": FieldValue.serverTimestamp(),
        });
        
        print('      ✅ Added to batch');
      }
      
      print('Committing batch with ${cartItems.length} documents...');
      await batch.commit();
      print('Successfully saved ${cartItems.length} items to Firestore!');
      
    } catch (e) {
    
      if (kDebugMode) {
        print("Failed to add cart stats: $e");
      }
    
      rethrow;
    }
  }

  Future<void> fetchStats() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection("productStats").get();
      
      if (snapshot.docs.isEmpty) {
        loading = false;
        notifyListeners();
        return;
      }

      _calculateStats(snapshot.docs);
      
      loading = false;
      notifyListeners();
    } catch (e) {
      error = "Failed to load stats: $e";
      loading = false;
      notifyListeners();
      print("Error fetching stats: $e");
    }
  }

  void _calculateStats(List<QueryDocumentSnapshot> docs) {
    totalSales = 0;
    totalRevenue = 0;
    totalProducts = 0;
    uniqueUsers = 0;
    uniqueProductsSold = 0;
    recentOrders = [];
    productSalesCount = {};
    topSpenders = {};
    categorySalesCount = {}; 

    Set<String> uniqueUserSet = {};
    Set<String> uniqueProductSet = {};
    Map<String, int> userSpending = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      final productName = data['productName'] ?? 'Unknown';
      int price = data['price'] ?? 0;
      int quantity = data['quantity'] ?? 1;
      final userName = data['userName'] ?? 'Guest';
      final productPic = data['productPic'] ?? '';
      final timestamp = data['timestamp'];
      final categoryName = data['categoryName'] ?? 'Uncategorized';

      totalSales++;
      totalRevenue += (price * quantity);
      totalProducts += quantity;

      uniqueUserSet.add(userName);
      uniqueProductSet.add(productName);

      productSalesCount[productName] = (productSalesCount[productName] ?? 0) + 1;
      userSpending[userName] = (userSpending[userName] ?? 0) + (price * quantity);
      categorySalesCount[categoryName] = (categorySalesCount[categoryName] ?? 0) + quantity;

      if (recentOrders.length < 10) {
        recentOrders.add({
          'productName': productName,
          'productPic': productPic,
          'price': price,
          'quantity': quantity,
          'userName': userName,
          'timestamp': timestamp,
          'total': price * quantity,
        });
      }
    }

    uniqueUsers = uniqueUserSet.length;
    uniqueProductsSold = uniqueProductSet.length;

    var sortedSpenders = userSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    topSpenders = Map.fromEntries(sortedSpenders.take(5));

    recentOrders.sort((a, b) {
      if (a['timestamp'] == null) return 1;
      if (b['timestamp'] == null) return -1;
      return (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp);
    });
  }

  List<MapEntry<String, int>> getTopSellingProducts({int limit = 5}) {
    var sorted = productSalesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  void listenToStats() {
    _firestore.collection("productStats").snapshots().listen(
      (snapshot) {
        _calculateStats(snapshot.docs);
        notifyListeners();
      },
      onError: (e) {
        error = "Error listening to stats: $e";
        notifyListeners();
      },
    );
  }

  Future<void> fetchStatsByDateRange(DateTime start, DateTime end) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection("productStats")
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      _calculateStats(snapshot.docs);
      
      loading = false;
      notifyListeners();
    } catch (e) {
      error = "Failed to load stats: $e";
      loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userName) async {
    try {
      final snapshot = await _firestore
          .collection("productStats")
          .where('userName', isEqualTo: userName)
          .get();

      int totalSpent = 0;
      int totalOrders = snapshot.docs.length;
      int itemsPurchased = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        int price = data['price'] ?? 0;
        int quantity = data['quantity'] ?? 1;
        totalSpent += (price * quantity);
        itemsPurchased += quantity;
      }

      return {
        'totalOrders': totalOrders,
        'totalSpent': totalSpent,
        'itemsPurchased': itemsPurchased,
      };
    } catch (e) {
      print("Error fetching user stats: $e");
      return {
        'totalOrders': 0,
        'totalSpent': 0,
        'itemsPurchased': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getProductStats(String productName) async {
    try {
      final snapshot = await _firestore
          .collection("productStats")
          .where('productName', isEqualTo: productName)
          .get();

      int totalSold = 0;
      int totalQuantity = 0;
      int totalRevenue = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        int price = data['price'] ?? 0;
        int quantity = data['quantity'] ?? 1;
        totalSold++;
        totalQuantity += quantity;
        totalRevenue += (price * quantity);
      }

      return {
        'totalSold': totalSold,
        'totalQuantity': totalQuantity,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      print("Error fetching product stats: $e");
      return {
        'totalSold': 0,
        'totalQuantity': 0,
        'totalRevenue': 0,
      };
    }
  }

  void clearStats() {
    totalSales = 0;
    totalRevenue = 0;
    totalProducts = 0;
    uniqueUsers = 0;
    uniqueProductsSold = 0;
    recentOrders = [];
    productSalesCount = {};
    topSpenders = {};
    loading = false;
    error = null;
    notifyListeners();
  }

  Future<void> refreshStats() async {
    await fetchStats();
  }

  int _touchedPieIndex = -1;
int get touchedPieIndex => _touchedPieIndex;
void setTouchedPieIndex(int index) {
  _touchedPieIndex = index;
  notifyListeners();
}

int _touchedBarIndex = -1;
int get touchedBarIndex => _touchedBarIndex;
void setTouchedBarIndex(int index) {
  _touchedBarIndex = index;
  notifyListeners();
}
}