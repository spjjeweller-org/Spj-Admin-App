import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spjjwellersadmin/models/customer.dart';

class Coupon {
  String? id;
  String couponId;
  String couponImage;
  String couponName;
  int couponStatus;
  DateTime createdAt;
  String customerId;
  
  Customer? customer;

  Coupon({
    required this.couponId,
    required this.couponImage,
    required this.couponName,
    required this.couponStatus,
    required this.createdAt,
    required this.customerId,
  });

  factory Coupon.fromRawJson(String str) => Coupon.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        couponId: json["coupon_id"],
        couponImage: json["coupon_image"],
        couponName: json["coupon_name"],
        couponStatus: json["coupon_status"],
        createdAt: DateTime.parse(json["created_at"].toDate().toString())
,
        customerId: json["customer_id"],
      );

  Map<String, dynamic> toJson() => {
        "coupon_id": couponId,
        "coupon_image": couponImage,
        "coupon_name": couponName,
        "coupon_status": couponStatus,
        "created_at": createdAt,
        "customer_id": customerId,
      };
}
