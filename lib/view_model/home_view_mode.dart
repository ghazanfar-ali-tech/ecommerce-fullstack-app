import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  bool _showCategories = false;

  String? _username;
  bool _isUsernameLoaded = false;

  final PageController pageController = PageController(
    viewportFraction: 0.8,
    keepPage: true,
  );
  int _currentPage = 0;
  int _currentCarouselIndex = 0;
  bool _isUserInteracting = false;
  bool _isSliderVisible = true;
  Timer? _autoScrollTimer;

  final Duration autoPlayInterval = Duration(seconds: 2);
  final Duration animationDuration = Duration(milliseconds: 500);

  VideoPlayerController? get videoController => _videoController;
  bool get isVideoInitialized => _isVideoInitialized;
  bool get hasVideoError => _hasVideoError;
  bool get showCategories => _showCategories;
  String? get username => _username;
  bool get isUsernameLoaded => _isUsernameLoaded;
  int get currentPage => _currentPage;
  int get currentCarouselIndex => _currentCarouselIndex;
  bool get isUserInteracting => _isUserInteracting;
  bool get isSliderVisible => _isSliderVisible;

  set currentCarouselIndex(int value) {
    _currentCarouselIndex = value;
    notifyListeners();
  }

  set isUserInteracting(bool value) {
    _isUserInteracting = value;
    notifyListeners();
  }


  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];

  bool _loading = false;
  bool get loading => _loading;

  StreamSubscription<QuerySnapshot>? _productsSubscription;
  StreamSubscription<User?>? _authSubscription;

  HomeViewModel() {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
    
        _listenToProducts();
      } else {
        _cancelProductsListener();
        allProducts = [];
        filteredProducts = [];
        notifyListeners();
      }
    });
  }

  Future<void> initialize() async {
    await _fetchUsername();
    await _initializeVideo();
    _startAutoScroll();
   
  }

  Future<void> _fetchUsername() async {
    final user = _auth.currentUser;
    
    if (user == null) {
      _username = 'anonymous_user';
      _isUsernameLoaded = true;
      notifyListeners();
      return;
    }

    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      
      if (snapshot.exists) {
        _username = snapshot.data()?['username'] ?? 
                    'user_${user.uid.substring(0, 8)}';
      } else {
        _username = 'user_${user.uid.substring(0, 8)}';
      }
      
      _isUsernameLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching username: $e");
      _username = 'user_${user.uid.substring(0, 8)}';
      _isUsernameLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://cdn.pixabay.com/video/2022/11/07/138076-768307870_large.mp4',
        ),
      );

      await _videoController!.initialize();
      
      _isVideoInitialized = true;
      notifyListeners();

      _videoController!.play();
      _videoController!.setVolume(0);

      Timer(Duration(seconds: 2), () {
        _showCategories = true;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Video initialization error: $e');
      _hasVideoError = true;
      notifyListeners();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(autoPlayInterval, (timer) {
      if (!_isSliderVisible || _isUserInteracting || !pageController.hasClients) {
        return;
      }

      _currentPage++;

      if (_currentPage >= 6) {
        _currentPage = 0;
        pageController.jumpToPage(0);
      } else {
        pageController.animateToPage(
          _currentPage,
          duration: animationDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void resumeAutoScroll() {
    _startAutoScroll();
  }

  Stream<QuerySnapshot> getCategoriesStream() {
    return _firestore
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void onProductTap(String productId) {
    debugPrint('Product tapped: $productId');
  }

  void onFavoriteTap(String productId) {
    debugPrint('Favorite tapped: $productId');
  }

  void onAddToCart(String productId) {
    debugPrint('Add to cart: $productId');
  }

  void _listenToProducts() {
    _productsSubscription?.cancel();
    
    _loading = true;
    notifyListeners();

    _productsSubscription = _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            allProducts = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();

            filteredProducts = List.from(allProducts);
            _loading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Products stream error: $error');
            if (error is FirebaseException && 
                error.code == 'permission-denied') {
              _cancelProductsListener();
              allProducts = [];
              filteredProducts = [];
            }
            _loading = false;
            notifyListeners();
          },
        );
  }

  void _cancelProductsListener() {
    _productsSubscription?.cancel();
    _productsSubscription = null;
  }

  void onSearch(String query) {
    if (query.isEmpty) {
      filteredProducts = List.from(allProducts);
    } else {
      filteredProducts = allProducts.where((product) {
        final name = (product['productName'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  

  void refresh() {
    if (_auth.currentUser != null) {
      _listenToProducts();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _autoScrollTimer?.cancel();
    pageController.dispose();
    _authSubscription?.cancel();
    _cancelProductsListener();
    super.dispose();
  }
}