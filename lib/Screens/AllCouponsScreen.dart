import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spjjwellersadmin/Screens/FillCouponsDetails.dart';
import 'package:spjjwellersadmin/Screens/AllCustomersScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spjjwellersadmin/Screens/LoginScreen.dart';
import 'package:spjjwellersadmin/global.dart';
import 'package:spjjwellersadmin/models/coupon.dart';
import 'package:spjjwellersadmin/models/customer.dart';

class AllCouponScreen extends StatefulWidget {
  String? customerId;
  String? customerName;
  String? customerPhoneNumber;
  AllCouponScreen(
      {super.key,
      this.customerId,
      this.customerPhoneNumber,
      this.customerName});

  @override
  State<AllCouponScreen> createState() => _AllCouponScreenState();
}

class _AllCouponScreenState extends State<AllCouponScreen> {
  List<Coupon> couponsList = [];
  List<Coupon> mainCouponList = [];
  bool loading = true;
  List<int> selectedStatus = [0, 1, 2];
  @override
  void initState() {
    widget.customerPhoneNumber == null
        ? fetchCoupons()
        : fetchCouponsByCustomerPhoneNumber();
    selectedStatus = [0, 1, 2];
    super.initState();
  }

  Future<void> fetchCouponsByCustomerPhoneNumber() async {
    setState(() {
      loading = true;
    });
    try {
      QuerySnapshot couponSnapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('customer_id', isEqualTo: widget.customerId)
          .get();

      List<DocumentSnapshot> sortedCoupons = couponSnapshot.docs
          .where((coupon) => coupon['created_at'] != null)
          .toList()
        ..sort((a, b) {
          // Sort coupons in descending order based on 'created_at'
          DateTime dateTimeA = (a['created_at'] as Timestamp).toDate();
          DateTime dateTimeB = (b['created_at'] as Timestamp).toDate();
          return dateTimeB.compareTo(dateTimeA);
        });

      for (DocumentSnapshot couponDocument in sortedCoupons) {
        Map<String, dynamic> couponData =
            couponDocument.data() as Map<String, dynamic>;
        Coupon coupon = Coupon.fromJson(couponData);
        coupon.id = couponDocument.id;
        // Fetch the associated customer data using the customer_id
        DocumentSnapshot<
            Map<String,
                dynamic>> customerSnapshot = await FirebaseFirestore.instance
            .collection('customers')
            .doc(coupon
                .customerId) // Use .doc() to reference the specific document
            .get();

        // If a matching customer document is found, extract and associate the customer data with the coupon.
        Map<String, dynamic> customerData =
            customerSnapshot.data() as Map<String, dynamic>;
        coupon.customer = Customer.fromJson(customerData);

        couponsList.add(coupon);
      }

      mainCouponList = couponsList;
    } catch (e) {
      // Handle any errors that may occur during the process.
      print("Error fetching coupons: $e");
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> fetchCoupons() async {
    setState(() {
      loading = true;
    });
    try {
      QuerySnapshot couponSnapshot =
          await FirebaseFirestore.instance.collection('coupons').get();

      List<DocumentSnapshot> sortedCoupons = couponSnapshot.docs
          .where((coupon) => coupon['created_at'] != null)
          .toList()
        ..sort((a, b) {
          // Sort coupons in descending order based on 'created_at'
          DateTime dateTimeA = (a['created_at'] as Timestamp).toDate();
          DateTime dateTimeB = (b['created_at'] as Timestamp).toDate();
          return dateTimeB.compareTo(dateTimeA);
        });

      for (DocumentSnapshot couponDocument in sortedCoupons) {
        Map<String, dynamic> couponData =
            couponDocument.data() as Map<String, dynamic>;
        Coupon coupon = Coupon.fromJson(couponData);
        coupon.id = couponDocument.id;
        // Fetch the associated customer data using the customer_id
        DocumentSnapshot<
            Map<String,
                dynamic>> customerSnapshot = await FirebaseFirestore.instance
            .collection('customers')
            .doc(coupon
                .customerId) // Use .doc() to reference the specific document
            .get();

        // If a matching customer document is found, extract and associate the customer data with the coupon.
        Map<String, dynamic> customerData =
            customerSnapshot.data() as Map<String, dynamic>;
        coupon.customer = Customer.fromJson(customerData);

        couponsList.add(coupon);
      }
      mainCouponList = couponsList;
    } catch (e) {
      // Handle any errors that may occur during the process.
      print("Error fetching coupons: $e");
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => widget.customerId == null
                  ? FillCouponsDetailsScreen()
                  : FillCouponsDetailsScreen(
                      customerNamee: widget.customerName,
                      customerPhoneNumberr: widget.customerPhoneNumber,
                    ),
            ),
          ).then((value) {
            setState(() {
              couponsList = [];
              widget.customerPhoneNumber == null
                  ? fetchCoupons()
                  : fetchCouponsByCustomerPhoneNumber();
            });
          });
        },
        backgroundColor: Color(0xFF1B1B1B),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('All Coupons',
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            )),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AllCustomersScreen(),
                ),
              );
            },
            icon: const Icon(Icons.people),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.black,
                      title: Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await signOut();
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.logout),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.69,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                couponsList = mainCouponList
                                    .where((element) => element.couponId
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                    .toList();
                              });
                            },
                            cursorColor: Colors.white,
                            cursorOpacityAnimates: true,
                            decoration: InputDecoration(
                              hintText: 'Coupon ID...',
                              fillColor: Theme.of(context).colorScheme.tertiary,
                              filled: true,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Icon(Icons.search),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Text(
                              'STATUS',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedStatus.contains(0)) {
                                        selectedStatus.remove(0);
                                      } else {
                                        selectedStatus.add(0);
                                      }
                                      print(selectedStatus);
                                      couponsList = mainCouponList
                                          .where((element) => selectedStatus
                                              .contains(element.couponStatus))
                                          .toList();
                                    });
                                    print(mainCouponList);
                                    print(couponsList);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selectedStatus.contains(0)
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 1,
                                        )),
                                    child: Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 13,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedStatus.contains(1)) {
                                        selectedStatus.remove(1);
                                      } else {
                                        selectedStatus.add(1);
                                      }
                                      couponsList = mainCouponList
                                          .where((element) => selectedStatus
                                              .contains(element.couponStatus))
                                          .toList();
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selectedStatus.contains(1)
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 1,
                                        )),
                                    child: Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 13,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedStatus.contains(2)) {
                                        selectedStatus.remove(2);
                                      } else {
                                        selectedStatus.add(2);
                                      }
                                      couponsList = mainCouponList
                                          .where((element) => selectedStatus
                                              .contains(element.couponStatus))
                                          .toList();
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selectedStatus.contains(2)
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 1,
                                        )),
                                    child: Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: couponsList.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext buildContext) {
                                    return AlertDialog(
                                      backgroundColor: Colors.black,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4),
                                            width: MediaQuery.of(buildContext)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    // Copy the coupon ID to the clipboard
                                                    Clipboard.setData(ClipboardData(
                                                        text:
                                                            "https://scracherspj.web.app/#/scratchcard/${couponsList[index].id}"));
                                                    // Show a snackbar or toast message to indicate the copy action
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            "Coupon Link copied to clipboard"),
                                                        duration: Duration(
                                                            seconds: 2),
                                                      ),
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons.copy,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "https://scracherspj.web.app/#/scratchcard/${couponsList[index].id}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: GoogleFonts.roboto(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Image.network(
                                            couponsList[index].couponImage,
                                            height: 200,
                                            width: 200,
                                            fit: BoxFit.fill,
                                          ),
                                          SizedBox(height: 20),
                                          SizedBox(
                                            height: 100,
                                            child: SingleChildScrollView(
                                              child: DefaultTextStyle(
                                                child: Text(couponsList[index]
                                                    .couponName),
                                                style: TextStyle(
                                                  fontFamily: 'Gilroy',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            String couponIdToDelete =
                                                couponsList[index].couponId;

                                            // Step 1: Delete the coupon document
                                            await FirebaseFirestore.instance
                                                .collection('coupons')
                                                .where('coupon_id',
                                                    isEqualTo: couponIdToDelete)
                                                .get()
                                                .then((QuerySnapshot
                                                    querySnapshot) {
                                              querySnapshot.docs.forEach((doc) {
                                                doc.reference.delete();
                                              });
                                            });
                                            final storageReference =
                                                FirebaseStorage
                                                    .instance
                                                    .refFromURL(
                                                        couponsList[index]
                                                            .couponImage);
                                            await storageReference.delete();
                                            print(
                                                'Image deleted successfully.');
                                            QuerySnapshot
                                                otherCouponsWithSameCustomerId =
                                                await FirebaseFirestore.instance
                                                    .collection('coupons')
                                                    .where('customer_id',
                                                        isEqualTo:
                                                            couponsList[index]
                                                                .customerId)
                                                    .get();

                                            if (otherCouponsWithSameCustomerId
                                                .docs.isEmpty) {
                                              await FirebaseFirestore.instance
                                                  .collection('customers')
                                                  .doc(couponsList[index]
                                                      .customerId)
                                                  .delete();
                                            }
                                            setState(() {
                                              couponsList.removeAt(index);
                                            }); // Refresh the UI

                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('coupons')
                                                  .where('coupon_id',
                                                      isEqualTo:
                                                          couponsList[index]
                                                              .couponId)
                                                  .get()
                                                  .then((QuerySnapshot
                                                      querySnapshot) {
                                                querySnapshot.docs
                                                    .forEach((doc) {
                                                  doc.reference.update(
                                                      {'coupon_status': 2});
                                                });
                                              });
                                              print(
                                                  'Coupon status updated successfully');
                                            } catch (e) {
                                              print(
                                                  'Error updating coupon status: $e');
                                            }
                                            couponsList[index].couponStatus = 2;
                                            setState(() {
                                              couponsList = couponsList;
                                            });
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text(
                                            'Redeem',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  color: Theme.of(context).colorScheme.tertiary,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: SizedBox(
                                            height: 150,
                                            width: 150,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 150,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 1,
                                                    ),
                                                    color: Colors.white,
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        couponsList[index]
                                                            .couponImage,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Opacity(
                                                  opacity:
                                                      0.5, // Adjust the opacity as needed (0.0 = fully transparent, 1.0 = fully opaque)
                                                  child: Container(
                                                    height: 150,
                                                    width: 150,
                                                    color: Colors
                                                        .white, // Change the color to adjust the translucency
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      couponsList[index]
                                                          .couponName
                                                          .toUpperCase(),
                                                      maxLines: 5,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          GoogleFonts.bangers(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        shadows: [
                                                          Shadow(
                                                            blurRadius:
                                                                10.0, // Adjust the blur radius for the shadow
                                                            color: Colors.white,
                                                            offset:
                                                                Offset(0, 0),
                                                          ),
                                                        ],
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Coupon ID',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      couponsList[index]
                                                          .couponId,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Name',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      couponsList[index]
                                                          .customer!
                                                          .customerName,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Phone no.',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      couponsList[index]
                                                          .customer!
                                                          .customerPhoneNumber,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Status',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    getStatus(
                                                        statusCode:
                                                            couponsList[index]
                                                                .couponStatus)
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Date',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat('dd/MM/yy')
                                                          .format(
                                                              couponsList[index]
                                                                  .createdAt)
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Time',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat('HH:mm')
                                                          .format(
                                                              couponsList[index]
                                                                  .createdAt)
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
