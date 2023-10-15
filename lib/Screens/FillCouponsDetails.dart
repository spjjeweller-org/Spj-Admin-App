import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spjjwellersadmin/models/coupon.dart';
import 'package:spjjwellersadmin/models/customer.dart';
import 'package:url_launcher/url_launcher.dart';

class FillCouponsDetailsScreen extends StatefulWidget {
  String? customerNamee;
  String? customerPhoneNumberr;
  FillCouponsDetailsScreen(
      {super.key, this.customerNamee, this.customerPhoneNumberr});

  @override
  State<FillCouponsDetailsScreen> createState() =>
      _FillCouponsDetailsScreenState();
}

class _FillCouponsDetailsScreenState extends State<FillCouponsDetailsScreen> {
  TextEditingController customerName = TextEditingController();
  TextEditingController customerPhoneNumber = TextEditingController();
  TextEditingController couponName = TextEditingController();
  File? couponImage;
  bool uploadedCouponImage = true;
  bool sendingData = true;
  String? uploadeddesignPNGName;
  bool loadCouponImage = true;
  Future<void> _pickPNG({required StateSetter innerSetState}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpeg'],
    );

    if (result != null) {
      couponImage = File(result.files.single.path!);

      innerSetState(() {
        uploadeddesignPNGName = result.files.single.name;
        uploadedCouponImage = true;
        print(
            "${couponImage.toString()}, ${uploadeddesignPNGName.toString()}, $uploadedCouponImage");
      });
    }
    innerSetState(() {
      loadCouponImage = false;
    });
  }

  Future<void> _pickAndCropImage({required StateSetter innerSetState}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      if (croppedFile != null) {
        innerSetState(() {
          couponImage = File(croppedFile.path);
          uploadeddesignPNGName =
              croppedFile.path.split('/').last; // Get the file name
          uploadedCouponImage = true;
          loadCouponImage = false;
        });
      }
    }
  }

  void showPermissionError() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Permission Denied"),
        content: Text(
            "You have permanently denied storage permission. Please enable it in app settings."),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Opens app settings for the user to manually enable the permission.
            },
          ),
        ],
      ),
    );
  }

  Future<void> requestPermissionsAndPickFile(BuildContext context) async {
    var status = await Permission.storage.status;
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    if (android.version.sdkInt < 33) {
      if (status.isGranted) {
        _pickAndCropImage(innerSetState: setState);
      } else if (status.isDenied) {
        var result = await Permission.storage.request();
        if (result.isGranted) {
          _pickAndCropImage(innerSetState: setState);
        } else {
          showPermissionError();
        }
      } else {
        showPermissionError();
      }
    } else {
      if (await Permission.photos.request().isGranted) {
        _pickAndCropImage(innerSetState: setState);
      } else if (await Permission.photos.request().isPermanentlyDenied) {
        showPermissionError();
      } else if (await Permission.photos.request().isDenied) {
        showPermissionError();
      }
    }
  }

  String generateRandomString(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String result = '';

    for (int i = 0; i < length; i++) {
      final randomIndex = random.nextInt(characters.length);
      result += characters[randomIndex];
    }

    return result;
  }

  Future<String?> uploadFileToStorage(
      String filePath, String folderName) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child(
          '$folderName/${DateTime.now().millisecondsSinceEpoch.toString()}');

      UploadTask uploadTask = storageReference.putFile(File(filePath));

      await uploadTask.whenComplete(() => null);

      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  String? customerId;
  Future<void> fetchCustomerId() async {
    FirebaseFirestore.instance
        .collection('customers')
        .where('customer_phone_number', isEqualTo: widget.customerPhoneNumberr)
        .get()
        .then((value) => {
              if (value.docs.length > 0)
                {
                  setState(() {
                    customerId = value.docs[0].id;
                  })
                }
            });
  }

  @override
  void initState() {
    if (widget.customerNamee != null && widget.customerPhoneNumberr != null) {
      customerName.text = widget.customerNamee!;
      customerPhoneNumber.text = widget.customerPhoneNumberr!;
      fetchCustomerId();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Fill Coupon Details',
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            )),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
        ),
        toolbarHeight: 100,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(20),
                  color: uploadedCouponImage ? Colors.white : Colors.red,
                  dashPattern: [2, 2],
                  child: Container(
                    height: 155,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                    child: couponImage != null
                        ? Stack(children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  couponImage!,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    couponImage = null;
                                    uploadedCouponImage = false;
                                    uploadeddesignPNGName = null;
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ])
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () => {
                                        requestPermissionsAndPickFile(context),
                                      },
                                  child: Icon(Icons.card_giftcard_outlined)),
                              SizedBox(
                                height: 16.0,
                              ),
                              DefaultTextStyle(
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                                child: Text(
                                  'Browse to Upload',
                                ),
                              ),
                              SizedBox(
                                height: 6.0,
                              ),
                              DefaultTextStyle(
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10.0,
                                    color: Color(0xFF9EA0A4),
                                  ),
                                  child: Text(
                                    "Supported formates: PNG",
                                  )),
                            ],
                          ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  controller: customerName,
                  onChanged: (value) {},
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.name,
                  cursorOpacityAnimates: true,
                  decoration: InputDecoration(
                    hintText: 'Customer name...',
                    fillColor: Theme.of(context).colorScheme.tertiary,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  controller: customerPhoneNumber,
                  maxLength: 10,
                  onChanged: (value) {},
                  cursorColor: Colors.white,
                  cursorOpacityAnimates: true,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Customer Phone No...',
                    fillColor: Theme.of(context).colorScheme.tertiary,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  height: 300,
                  width: double.infinity,
                  child: TextField(
                    controller: couponName,
                    maxLines: 200,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      fillColor: const Color(0xff3B3B3B),
                      filled: true,
                      hintText: 'Coupon details...',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                      onPressed: () {
                        if (customerName.text.trim() == "" ||
                            customerPhoneNumber.text.trim() == "" ||
                            customerPhoneNumber.text.trim().length < 10 ||
                            couponImage == null ||
                            couponName.text.trim() == "") {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please fill all the details'),
                            duration: Duration(seconds: 2),
                          ));
                          return;
                        }
                        setState(() {
                          sendingData = false;
                        });
                        uploadFileToStorage(couponImage!.path, 'coupons')
                            .then((value) async {
                          print(value);
                          if (value != null) {
                            print(value);
                            late DocumentReference customerRef;
                            await FirebaseFirestore.instance
                                .collection('customers')
                                .where('customer_phone_number',
                                    isEqualTo: customerPhoneNumber.text)
                                .get()
                                .then((value) async => {
                                      if (value.docs.length > 0)
                                        {customerId = value.docs[0].id}
                                      else
                                        {
                                          customerRef = await FirebaseFirestore
                                              .instance
                                              .collection('customers')
                                              .add(Customer(
                                                customerName: customerName.text,
                                                customerPhoneNumber:
                                                    customerPhoneNumber.text,
                                              )
                                                  .toJson()
                                                  .cast<String, dynamic>())
                                        }
                                    });

                            await FirebaseFirestore.instance
                                .collection('coupons')
                                .add(Coupon(
                                  couponId: generateRandomString(7),
                                  couponImage: value,
                                  couponName: couponName.text,
                                  couponStatus: 0,
                                  createdAt: DateTime.now(),
                                  customerId: customerId ?? customerRef.id,
                                ).toJson().cast<String, dynamic>())
                                .then((value) async {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      "https://scracherspj.web.app/#/scratchcard/${value.id}"));
                              // Show a snackbar or toast message to indicate the copy action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Coupon Link copied to clipboard"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              String message ="https://scracherspj.web.app/#/scratchcard/${value.id}";

                              String encodedMessage =
                                  Uri.encodeComponent(message);
                              Uri url = Uri.parse(
                                  "https://wa.me/91${customerPhoneNumber.text.trim()}/?text=$encodedMessage");
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            });
                            setState(() {
                              sendingData = true;
                            });
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              sendingData = false;
                            });
                          }
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            !sendingData ? Colors.grey : Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        textStyle: TextStyle(
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                        ),
                      ),
                      child: !sendingData
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Text('Generating Link...'),
                                SizedBox(
                                  width: 10.0,
                                ),
                                SizedBox(
                                  height: 15.0,
                                  width: 15.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Generate Coupon',
                              style: TextStyle(
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                              ),
                            )),
                ),
              ],
            )),
      ),
    );
  }
}
