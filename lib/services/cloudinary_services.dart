import 'dart:io';
import 'package:ecommerceapp/core/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static String get uploadPreset => AppConstants.uploadPreset;

    
  
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudName}/image/upload'
      );

      final request = http.MultipartRequest('POST', url);
      
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path)
      );

      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete image from Cloudinary (optional)
  static Future<bool> deleteImage(String publicId) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudName}/image/destroy'
      );

      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'api_key': AppConstants.cloudinaryApiKey,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}