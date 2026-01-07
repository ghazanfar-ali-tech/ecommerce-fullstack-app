import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();

  void init(BuildContext context) {
    // App opened from terminated state
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleUri(context, uri);
      }
    });

    // App opened from background
    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(context, uri);
    });
  }
    Future<Uri?> getInitialDeepLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (_) {
      return null;
    }
  }

  void _handleUri(BuildContext context, Uri uri) {
    if (uri.pathSegments.isEmpty) return;

    if (uri.pathSegments.first == 'product') {
      final productId = uri.pathSegments[1];

      Navigator.pushNamed(
        context,
        '/product',
        arguments: productId,
      );
    }
  }
}
