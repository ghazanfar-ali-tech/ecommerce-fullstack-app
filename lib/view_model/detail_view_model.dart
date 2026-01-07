
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailViewModel extends ChangeNotifier{

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   int _price = 0;
   int get price => _price;



    Stream<QuerySnapshot> getProductsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}