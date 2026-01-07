import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'address.g.dart';

@HiveType(typeId: 0)
class Address extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String street;

  @HiveField(3)
  String city;

  @HiveField(4)
  String state;

  @HiveField(5)
  String zip;

  @HiveField(6)
  String country;

  @HiveField(7)
  bool isDefault;

  Address({
    String? id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    this.isDefault = false,
  }) : id = id ?? const Uuid().v4();
}