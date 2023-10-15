import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spjjwellersadmin/Screens/AllCouponsScreen.dart';
import 'package:spjjwellersadmin/Screens/FillCouponsDetails.dart';
import 'package:spjjwellersadmin/Screens/LoginScreen.dart';
import 'package:spjjwellersadmin/global.dart';
import 'package:spjjwellersadmin/models/coupon.dart';
import 'package:spjjwellersadmin/models/customer.dart';

class AllCustomersScreen extends StatefulWidget {
  const AllCustomersScreen({super.key});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  bool loading = true;

  List<Customer> mainCustomerList = [];
  List<Customer> customerList = [];
  Future<void> fetchCustomer() async {
    setState(() {
      loading = true;
    });
    try {
      QuerySnapshot customerSnapshot =
          await FirebaseFirestore.instance.collection('customers').get();

      for (QueryDocumentSnapshot customerDocument in customerSnapshot.docs) {
        Map<String, dynamic> customerData =
            customerDocument.data() as Map<String, dynamic>;
        Customer customer = Customer.fromJson(customerData);
        customer.customerId = customerDocument.id;
        print(customer);
        // Fetch the associated coupon data for the current customer
        QuerySnapshot couponsSnapshot = await FirebaseFirestore.instance
            .collection('coupons')
            .where('customer_id', isEqualTo: customerDocument.id)
            .get();
        List<DocumentSnapshot> sortedCoupons = couponsSnapshot.docs
            .where((coupon) => coupon['created_at'] != null)
            .toList()
          ..sort((a, b) {
            // Sort coupons in descending order based on 'created_at'
            DateTime dateTimeA = (a['created_at'] as Timestamp)
                .toDate(); // Convert Firestore Timestamp to DateTime
            DateTime dateTimeB = (b['created_at'] as Timestamp).toDate();
            return dateTimeB.compareTo(dateTimeA);
          });

        // If the customer has a coupon, fetch the coupon data
        Map<String, dynamic> couponData =
            sortedCoupons.first.data() as Map<String, dynamic>;
        Coupon coupon = Coupon.fromJson(couponData);
        print(couponData);
        customer.lastCoupon = coupon;
        customerList.add(customer);
      }
      customerList.reversed;
      mainCustomerList = customerList;
    } catch (e) {
      // Handle any errors that may occur during the process.
      print("Error fetching coupons and customers: $e");
    }
    setState(() {
      loading = false;
    });
  }

  List<int> selectedStatus = [0, 1, 2];

  @override
  void initState() {
    fetchCustomer();

    selectedStatus = [0, 1, 2];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => FillCouponsDetailsScreen(),
            ),
          ).then((value) {
            customerList = [];
            fetchCustomer();
          });
        },
        backgroundColor: Color(0xFF1B1B1B),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('All Customers',
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
                  builder: (context) => AllCouponScreen(),
                ),
              );
            },
            icon: const Icon(Icons.card_giftcard),
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
                              if (value.toString().trim() != "") {
                                setState(() {
                                  customerList = mainCustomerList
                                      .where((customer) =>
                                          customer.customerName
                                              .toLowerCase()
                                              .contains(value.toLowerCase()) ||
                                          customer.customerPhoneNumber
                                              .contains(value))
                                      .toList();
                                });
                              }
                            },
                            cursorColor: Colors.white,
                            cursorOpacityAnimates: true,
                            decoration: InputDecoration(
                              hintText: 'Customer name...',
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
                                      customerList = mainCustomerList
                                          .where((element) =>
                                              selectedStatus.contains(element
                                                  .lastCoupon!.couponStatus))
                                          .toList();
                                    });
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
                                      customerList = mainCustomerList
                                          .where((element) =>
                                              selectedStatus.contains(element
                                                  .lastCoupon!.couponStatus))
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
                                      customerList = mainCustomerList
                                          .where((element) =>
                                              selectedStatus.contains(element
                                                  .lastCoupon!.couponStatus))
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
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: customerList.length,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => AllCouponScreen(
                                          customerId:
                                              customerList[index].customerId,
                                          customerName:
                                              customerList[index].customerName,
                                          customerPhoneNumber:
                                              customerList[index]
                                                  .customerPhoneNumber,
                                        )),
                              ).then((value) {
                                customerList = [];
                                fetchCustomer();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              color: Theme.of(context).colorScheme.tertiary,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: double.infinity,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                                color: Colors.white,
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    customerList[index]
                                                        .lastCoupon!
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
                                                height: double.infinity,
                                                width: double.infinity,
                                                color: Colors
                                                    .white, // Change the color to adjust the translucency
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  customerList[index]
                                                      .lastCoupon!
                                                      .couponName,
                                                  maxLines: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.bangers(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    shadows: [
                                                      Shadow(
                                                        blurRadius:
                                                            10.0, // Adjust the blur radius for the shadow
                                                        color: Colors.white,
                                                        offset: Offset(0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Name',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        customerList[index].customerName,
                                        overflow: TextOverflow.ellipsis,
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
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Phone no.',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        customerList[index].customerPhoneNumber,
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
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Status',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        getStatus(
                                            statusCode: customerList[index]
                                                .lastCoupon!
                                                .couponStatus),
                                      ]),
                                ],
                              ),
                            ),
                          ),
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
