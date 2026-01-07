import 'package:ecommerceapp/utils/utils.dart';
import 'package:ecommerceapp/views/auth_screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewModel extends ChangeNotifier {
  String? _userRole;
  String? _userId;
  String? _email;
  
  String? get userRole => _userRole;
  String? get userId => _userId;
  String? get email => _email;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  
  bool _loading = false;
  bool get loading => _loading;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
  
  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    try {
      // 1. Clear SharedPreferences FIRST
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userRole');
      await prefs.remove('userId');
      await prefs.remove('email');
      
      // 2. Clear in-memory state
      _userRole = null;
      _userId = null;
      _email = null;
      _emailController.clear();
      _passwordController.clear();
      
      // 3. Sign out from Firebase (this triggers authStateChanges)
      await _auth.signOut();
      
      // 4. Small delay to allow listeners to process the auth state change
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 5. Navigate safely
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) =>  AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      Utils.toastMessage('Error during logout. Please try again.');
    } finally {
      _setLoading(false);
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}