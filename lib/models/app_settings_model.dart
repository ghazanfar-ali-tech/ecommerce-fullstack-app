class AppSettings {
  final String id;
  final String storeName;
  final String storeLogo;
  final String supportEmail;
  final String storeInfo;
  final String currencySymbol;

  AppSettings({
    required this.id,
    required this.storeName,
    required this.storeLogo,
    required this.supportEmail,
    required this.storeInfo,
    required this.currencySymbol,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'storeLogo': storeLogo,
      'supportEmail': supportEmail,
      'storeInfo': storeInfo,
      'currencySymbol': currencySymbol,
    };
  }

  factory AppSettings.fromMap(String id, Map<String, dynamic> map) {
    return AppSettings(
      id: id,
      storeName: map['storeName'] ?? '',
      storeLogo: map['storeLogo'] ?? '',
      supportEmail: map['supportEmail'] ?? '',
      storeInfo: map['storeInfo'] ?? '',
      currencySymbol: map['currencySymbol'] ?? '',
    );
  }

  AppSettings copyWith({
    String? id,
    String? storeName,
    String? storeLogo,
    String? supportEmail,
    String? storeInfo,
    String? currencySymbol,
  }) {
    return AppSettings(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      storeLogo: storeLogo ?? this.storeLogo,
      supportEmail: supportEmail ?? this.supportEmail,
      storeInfo: storeInfo ?? this.storeInfo,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}