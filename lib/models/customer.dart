import 'dart:convert';

import 'package:spjjwellersadmin/models/coupon.dart';

class Customer {
  String? customerId;
  String? customerImage;
  String customerName;
  String customerPhoneNumber;
  Coupon? lastCoupon;
  Customer({
    required this.customerName,
    required this.customerPhoneNumber,
  });

  factory Customer.fromRawJson(String str) =>
      Customer.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        customerName: json["customer_name"],
        customerPhoneNumber: json["customer_phone_number"],
      );

  Map<String, dynamic> toJson() => {
        "customer_name": customerName,
        "customer_phone_number": customerPhoneNumber,
      };
}
