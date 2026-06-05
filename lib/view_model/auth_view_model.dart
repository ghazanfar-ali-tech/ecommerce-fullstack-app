import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:ecommerceapp/services/notification_services.dart/push_notification_services.dart';
import 'package:ecommerceapp/utils/utils.dart';
import 'package:ecommerceapp/view_model/google_sign.dart';
import 'package:ecommerceapp/view_model/notification_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/views/admin_screens/admin_panel_screen.dart';
import 'package:ecommerceapp/views/auth_screens/auth_screen.dart';
import 'package:ecommerceapp/views/bottom_navigation/bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthViewModel extends ChangeNotifier {
  String? _userRole;
  String? _userId;
  String? _email;

  bool _isLoginSelected = true;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get isLoginSelected => _isLoginSelected;
  TextEditingController get emailController => _emailController;
  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;
  bool get obscurePassword => _obscurePassword;
  String? get userRole => _userRole;
  String? get userId => _userId;
  String? get email => _email;

  bool _loading = false;
  bool get loading => _loading;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void selectLogin() {
    _isLoginSelected = true;
    notifyListeners();
  }

  void selectSignIn() {
    _isLoginSelected = false;
    notifyListeners();
  }

  bool get isAdmin => _userRole?.toLowerCase() == 'admin';

  Future<void> signUp(
    BuildContext context,
    NotificationViewModel notificationVM,
  ) async {
    _setLoading(true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCredential.user!.uid,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Utils.toastMessage('Account created successfully!');
      notificationVM.showNotification(
        'SignUP Successful',
        'Account created successfully!',
      );
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }
      debugPrint(errorMessage);
      Utils.toastMessage(errorMessage);
    } catch (e) {
      debugPrint(e.toString());
      Utils.toastMessage('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveToPrefs(String role, String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
    print('Saved to prefs - Role: $role, UserId: $userId, Email: $email');
  }

  Future<void> loadUserFromPrefs(StoreViewModel storeVM) async {
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('userRole');
    _userId = prefs.getString('userId');
    _email = prefs.getString('email');

    if (_userId != null) {
      await openUserCart(_userId!);
      await storeVM.initForUser(_userId!);
    }

    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _setLoading(true);

    try {
      final storeVM = Provider.of<StoreViewModel>(context, listen: false);
      storeVM.clearFavorites();
      await _auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userRole');
      await prefs.remove('userId');
      await prefs.remove('email');

      if (_cartBox != null && _cartBox!.isOpen) {
        await _cartBox!.close();
      }

      _userRole = null;
      _userId = null;
      _email = null;
      _cartBox = null;

      _emailController.clear();
      _passwordController.clear();

      notifyListeners();

      await FirebaseMessaging.instance.unsubscribeFromTopic('new_products');

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      Utils.toastMessage('Error during logout. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(
    BuildContext context,
    NotificationViewModel notificationVM,
  ) async {
    _setLoading(true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await PushNotificationService.instance.saveTokenToFirestore();
      final user = userCredential.user!;
      _userId = user.uid;
      _email = user.email;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      _userRole = userDoc.data()?['role'] ?? 'user';

      await _saveToPrefs(_userRole!, _userId!, _email!);

      await openUserCart(_userId!);

      final storeVM = Provider.of<StoreViewModel>(context, listen: false);
      await storeVM.initForUser(_userId!);

      Utils.toastMessage(
        'Welcome, ${_userRole == 'admin' ? 'Admin' : 'User'}!',
      );
      notificationVM.showNotification('Login Successful', 'Welcome back!');

      await context.read<NotificationViewModel>().init();

      _emailController.clear();
      _passwordController.clear();

      if (_userRole?.toLowerCase() == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => AdminPanelContainerScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => BottomNavigation()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }
      debugPrint(errorMessage);
      Utils.toastMessage(errorMessage);
    } catch (e) {
      debugPrint(e.toString());
      Utils.toastMessage('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> loginWithGoogle(BuildContext context) async {
    try {
      _setLoading(true);

      final result = await GoogleSignInService.signInWithGoogle();

      print("Google sign-in result: $result");
      print("User: ${result?.user}");

      if (result?.user != null) {
        final user = result!.user!;
        _userId = user.uid;
        _email = user.email;
        await PushNotificationService.instance.saveTokenToFirestore();
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'username': user.displayName ?? 'User',
            'email': user.email,
            'uid': user.uid,
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
          _userRole = 'user';
        } else {
          _userRole = userDoc.data()?['role'] ?? 'user';
        }

        await _saveToPrefs(_userRole!, _userId!, _email!);

        await openUserCart(_userId!);
        final storeVM = Provider.of<StoreViewModel>(context, listen: false);
        await storeVM.initForUser(_userId!);
      }

      _setLoading(false);
      return result?.user;
    } catch (e) {
      _setLoading(false);
      print("Error in loginWithGoogle: $e");
      Utils.toastMessage('Google Login Error: $e');
      return null;
    }
  }

  Box<CartModel>? _cartBox;

  Future<void> openUserCart(String uid) async {
    try {
      final boxName = 'cart_$uid';

      if (_cartBox != null && _cartBox!.isOpen) {
        await _cartBox!.close();
      }

      if (!Hive.isBoxOpen(boxName)) {
        _cartBox = await Hive.openBox<CartModel>(boxName);
      } else {
        _cartBox = Hive.box<CartModel>(boxName);
      }

      print('Opened cart for user: $uid (${_cartBox!.length} items)');
    } catch (e) {
      print('Error opening cart: $e');
      rethrow;
    }
  }

  Box<CartModel> getCartBox() {
    if (_cartBox == null || !_cartBox!.isOpen) {
      throw Exception('Cart box is not opened! User might not be logged in.');
    }
    return _cartBox!;
  }

  int getCartItemCount() {
    try {
      return _cartBox?.length ?? 0;
    } catch (e) {
      return 0;
    }
  }

  int getTotalCartValue() {
    try {
      if (_cartBox == null || !_cartBox!.isOpen) return 0;

      int total = 0;
      for (var i = 0; i < _cartBox!.length; i++) {
        final item = _cartBox!.getAt(i)!;
        total += item.productPrice * item.quantity;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearCart() async {
    try {
      if (_cartBox != null && _cartBox!.isOpen) {
        await _cartBox!.clear();
        notifyListeners();
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  Future<User?> loginWithFacebook(BuildContext context) async {
    try {
      _setLoading(true);

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        Utils.toastMessage('Facebook login cancelled or failed.');
        return null;
      }

      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      _userId = user.uid;
      _email = user.email;

      await PushNotificationService.instance.saveTokenToFirestore();

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': user.displayName ?? 'User',
          'email': user.email ?? '',
          'uid': user.uid,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _userRole = 'user';
      } else {
        _userRole = userDoc.data()?['role'] ?? 'user';
      }

      await _saveToPrefs(_userRole!, _userId!, _email!);
      await openUserCart(_userId!);

      final storeVM = Provider.of<StoreViewModel>(context, listen: false);
      await storeVM.initForUser(_userId!);

      _setLoading(false);
      return user;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      Utils.toastMessage('Firebase error: ${e.message}');
      return null;
    } catch (e) {
      _setLoading(false);
      debugPrint('Facebook login error: $e');
      Utils.toastMessage('Facebook login failed: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
