import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/hive_models/shipping_address/address.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class AddressViewModel extends ChangeNotifier {
  List<Address> _addresses = [];
  bool _isLoading = true;
  Box<Address>? _box;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

   AddressViewModel() {
    _auth.authStateChanges().listen((user) {
      _onAuthChanged(user);
    });
  }

  
  Future<void> _onAuthChanged(User? user) async {
    _isLoading = true;
    notifyListeners();

    if (_box?.isOpen == true) {
      await _box!.close();
    }

    _addresses = [];

    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _box = await Hive.openBox<Address>('addresses_${user.uid}');

    await _loadFromHive();
    await _fetchFromFirestore(user.uid);

    _isLoading = false;
    notifyListeners();
  }


  String? getUserId() {
    return _auth.currentUser?.uid; 
  }

  Future<void> _loadFromHive() async {
    _addresses = _box?.values.toList() ?? [];
    notifyListeners();
  }

  Future<void> _fetchFromFirestore(String userId) async {
    try {
      final collection = _firestore.collection('users').doc(userId).collection('addresses');
      final snapshot = await collection.get();
      final firestoreAddresses = snapshot.docs.map((doc) {
        final data = doc.data();
        return Address(
          id: doc.id,
          name: data['name'],
          street: data['street'],
          city: data['city'],
          state: data['state'],
          zip: data['zip'],
          country: data['country'],
          isDefault: data['isDefault'] ?? false,
        );
      }).toList();

      if (_hasChanges(firestoreAddresses)) {
        _addresses = firestoreAddresses;
        await _saveToHive();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
    }
  }

  bool _hasChanges(List<Address> newAddresses) {
    if (newAddresses.length != _addresses.length) return true;
    for (int i = 0; i < newAddresses.length; i++) {
      if (newAddresses[i].id != _addresses[i].id || newAddresses[i].name != _addresses[i].name ) {
        return true;
      }
    }
    return false;
  }

  Future<void> _saveToHive() async {
    await _box?.clear();
    for (var address in _addresses) {
      await _box?.put(address.id, address);
    }
  }

  Future<void> _handleDefault(Address address, String userId) async {
    if (address.isDefault) {
      for (var addr in _addresses) {
        if (addr.id != address.id && addr.isDefault) {
          addr.isDefault = false;
          await updateAddress(addr, notify: false);
        }
      }
    }
  }

  Future<void> addAddress(Address address) async {
    final userId = getUserId();
    if (userId == null) return;

    try {
      final collection = _firestore.collection('users').doc(userId).collection('addresses');
      final docRef = await collection.add({
        'name': address.name,
        'street': address.street,
        'city': address.city,
        'state': address.state,
        'zip': address.zip,
        'country': address.country,
        'isDefault': address.isDefault,
      });
      address.id = docRef.id; // Update ID from Firestore

      await _handleDefault(address, userId);

      _addresses.add(address);
      await _box?.put(address.id, address);
      notifyListeners();
    } catch (e) {
      debugPrint('Add error: $e');
    }
  }

  Future<void> updateAddress(Address address, {bool notify = true}) async {
    final userId = getUserId();
    if (userId == null) return;

    try {
      final collection = _firestore.collection('users').doc(userId).collection('addresses');
      await collection.doc(address.id).update({
        'name': address.name,
        'street': address.street,
        'city': address.city,
        'state': address.state,
        'zip': address.zip,
        'country': address.country,
        'isDefault': address.isDefault,
      });

      await _handleDefault(address, userId);

      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
        await _box?.put(address.id, address);
        if (notify) notifyListeners();
      }
    } catch (e) {
      debugPrint('Update error: $e');
    }
  }

  Future<void> deleteAddress(String id) async {
    final userId = getUserId();
    if (userId == null) return;

    try {
      final collection = _firestore.collection('users').doc(userId).collection('addresses');
      await collection.doc(id).delete();
      _addresses.removeWhere((a) => a.id == id);
      await _box?.delete(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Address? get checkoutAddress {
  if (_addresses.isEmpty) return null;

  final defaultAddress = _addresses.where((a) => a.isDefault).toList();
  if (defaultAddress.isNotEmpty) {
    return defaultAddress.first;
  }

  return _addresses.first;
}

}