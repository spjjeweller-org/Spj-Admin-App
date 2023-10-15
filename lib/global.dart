import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spjjwellersadmin/models/coupon.dart';
import 'package:spjjwellersadmin/models/customer.dart';



Widget getStatus({required int statusCode}) {
  switch (statusCode) {
    case 0:
      return Text(
        'Pending',
        style: TextStyle(
          color: Colors.red,
          fontSize: 13,
        ),
      );
    case 1:
      return Text(
        'Scrached',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 13,
        ),
      );
    case 2:
      return Text(
        'Redeemed',
        style: TextStyle(
          color: Colors.green,
          fontSize: 13,
        ),
      );
    default:
      return Text(
        'Pending',
        style: TextStyle(
          color: Colors.red,
          fontSize: 13,
        ),
      );
  }
}
Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    // You can also navigate to a different screen or do other actions after sign-out.
  } catch (e) {
    print("Error signing out: $e");
  }
}
