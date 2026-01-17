import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/app_settings_model.dart';
import 'package:flutter/foundation.dart';

class AppSettingsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'settingsCollection';
  
  AppSettings? _settings;
  bool _isLoading = false;
  String? _error;

  AppSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createSettings(AppSettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection(collectionName).doc(settings.id).set(settings.toMap());
      _settings = settings;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSettings(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();
      if (doc.exists) {
        _settings = AppSettings.fromMap(doc.id, doc.data()!);
      } else {
        _error = 'Settings not found';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(String id, AppSettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection(collectionName).doc(id).update(settings.toMap());
      _settings = settings;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSettings(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection(collectionName).doc(id).delete();
      _settings = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<AppSettings?> streamSettings(String id) {
    return _firestore.collection(collectionName).doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return AppSettings.fromMap(doc.id, doc.data()!);
      }
      return null;
    });
  }
}