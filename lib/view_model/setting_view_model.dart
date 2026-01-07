import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingViewModel extends ChangeNotifier {
  final FirebaseFirestore _firebaseStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'ds7vlzkev',
    'cloud_storage',
    cache: false,
  );

  String? _error;
  String? _profilePhotoUrl;
  String? _username;
  String? _userEmail;
  bool _isLoading = false;
  File? _selectedImage;

  String? get profilePhotoUrl => _profilePhotoUrl;
  String? get username => _username;
  String? get userGamil => _userEmail;
  String? get error => _error;
  bool get isLoading => _isLoading;
  File? get selectedImage => _selectedImage;

  void setSelectedImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void removeProfilePhoto() {
    _selectedImage = null;
    _profilePhotoUrl = null;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    if (_auth.currentUser == null) return;

    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final doc = await _firebaseStore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _username = data['username'];
        _userEmail = data['email'];
        _profilePhotoUrl = data['profilePhotoUrl'];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadProfilePhoto(File imageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profile_photos',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      _error = 'Failed to upload image: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<bool> saveProfile({
    String? username,
    String? userEmail,
  }) async {
    if (_auth.currentUser == null) {
      _error = 'Please log in to update profile';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updateData = <String, dynamic>{};

      if (_selectedImage != null) {
        final imageUrl = await uploadProfilePhoto(_selectedImage!);
        if (imageUrl != null) {
          updateData['profilePhotoUrl'] = imageUrl;
          _profilePhotoUrl = imageUrl;
        } else {
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (_selectedImage == null && _profilePhotoUrl == null) {
        updateData['profilePhotoUrl'] = null;
      }

      if (username != null && username.isNotEmpty) {
        updateData['username'] = username;
        _username = username;
      }

      if (userEmail != null && userEmail.isNotEmpty) {
        updateData['email'] = userEmail;
        _userEmail = userEmail;
      }


      if (updateData.isNotEmpty) {
        await _firebaseStore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update(updateData);
      }

      _selectedImage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateUserProfile({
    String? username,
    String? userEmail,
  }) async {
    if (_auth.currentUser == null) {
      _error = 'Please log in to update profile';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updateData = <String, dynamic>{};

      if (username != null && username.isNotEmpty) {
        updateData['username'] = username;
      }

      if (userEmail != null && userEmail.isNotEmpty) {
        updateData['email'] = userEmail;
      }

      if (updateData.isNotEmpty) {
        await _firebaseStore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update(updateData);

        if (username != null) _username = username;
        if (userEmail != null) _userEmail = userEmail;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}