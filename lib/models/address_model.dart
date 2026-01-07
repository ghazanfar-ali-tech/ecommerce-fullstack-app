import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String city, country, name, state, street, zip,id;

  AddressModel({
    required this.id,
    required this.city,
    required this.country,
    required this.name,
    required this.state,
    required this.street,
    required this.zip,
  });

  Map<String, dynamic> toMap(){

    return {
      "city":city,
      "country":country,
      "name":name,
      "state":state,
      "street":street,
      "zip":zip,
    };

  }

    factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      city: data["city"] ?? "",
      country: data["country"] ?? "", 
      name: data["name"] ?? "",
      state: data["state"] ?? "",
      street: data["street"] ?? "",
      zip: data["zip"] ?? "",

    );
  }

    AddressModel copyWith({
    String? id,
    String? city,
    String? country,
    String? name,
    String? state,
    String? street,
    String? zip,
  }) {
    return AddressModel(
      id: id ?? this.id,
      city: city ?? this.city,
      country: country ?? this.country,
      name:  name ?? this.name,
      state: state ?? this.state,
      street: street ?? this.street,
      zip: zip ?? this.zip,
    );
  }

}
