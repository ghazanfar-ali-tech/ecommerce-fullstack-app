import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionInfoViewModel extends ChangeNotifier{

    PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

 PackageInfo get packageInfo => _packageInfo;
 
 Future<void> loadPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    notifyListeners();
  }

}