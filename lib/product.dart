import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'helpers/producttextfield.dart'; // Assuming this contains your custom TextField widget
import 'auth/logIn.dart';
import 'helpers/textfield1.dart';
import 'homescreen/homescreen.dart'; // Import homescreen to access the homescreen.home constant

class product extends StatefulWidget {
  static const productpage = '/product';
  String pname = '';
  String id= '';
  product({
    super.key,
    required this.pname,
    required this.id
  });

  @override
  State<product> createState() => _productState();
}

class _productState extends State<product> {
  bool _loading = false;
  TextEditingController pnameController = TextEditingController();
  TextEditingController trackingid = TextEditingController();
  TextEditingController cnameController = TextEditingController();
  final phoneController = MaskedTextController(mask: "00000-000000");
  TextEditingController addressController = TextEditingController();
  TextEditingController postController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController variationsController = TextEditingController();
  List<dynamic> variations = [];

  String productname = '',
      customer = '',
      phonenumber = '',
      caddress = '',
      cpost = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Function to fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      // Replace 'user_email' with the actual email of the user
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userEmail)
          .get();

      if (userDoc.exists) {

        // Assuming subcollection 'orders' and document 'pname' exist
        DocumentSnapshot<Map<String, dynamic>> orderDoc = await userDoc
            .reference
            .collection('orders')
            .doc(widget.id)
            .get();

        if (orderDoc.exists) {
          Map<String, dynamic> orderData = orderDoc.data() ?? {};

          setState(() {
            pnameController.text = orderData['pname'] ?? '';
            cnameController.text = orderData['cname'] ?? '';
            phoneController.text = orderData['phone'] ?? '';
            addressController.text = orderData['address'] ?? '';
            postController.text = orderData['post'] ?? '';
            trackingid.text = orderData['tid'] ?? '';
            serviceController.text = orderData['selectedservice'] ?? '';
            variations = orderData['variations']??'';
            variationsController.text = variations.join(',');
            print('this is variations ${variationsController.text}');
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Function to update user data in Firestore
  Future<void> updateUserData() async {
    setState(() {
      _loading = true;
    });
    try {
      // Replace 'user_email' with the actual email of the user
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      DocumentReference<Map<String, dynamic>> orderDocReference =
          FirebaseFirestore.instance
              .collection('users')
              .doc(userEmail)
              .collection('orders')
              .doc(widget.id);
      List<String> variationsList = variationsController.text.split(',');
      print('this is updated variation list ${variationsList}');

      await orderDocReference.set({
        'pname': pnameController.text,
        'cname': cnameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'post': postController.text,
        'variations':variationsList
      }, SetOptions(merge: true));
      setState(() {
        _loading = false;
      });
      // Display a success message or navigate to another screen after saving
      print('Data saved successfully!');
    } catch (e) {
      print('Error updating user data: $e');
      // Handle errors or display an error message
    } finally {
      Navigator.pushReplacementNamed(context, homescreen.home);
    }
  }

  Future<void> deleteOrder() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      // Get a reference to the document to be deleted
      DocumentReference orderDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('orders')
          .doc(widget.id);

      DocumentReference orderDocRef1 = FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.id);

      // Delete the document
      await orderDocRef.delete();
      await orderDocRef1.delete();

      print('Document deleted successfully');
      Navigator.pushReplacementNamed(context, homescreen.home);
    } catch (e) {
      print('Error deleting document: $e');
      // Handle errors
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color customColor = HexColor("#fd7b2e");


    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, homescreen.home);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: customColor,
          title: const Text(
            'Order Details',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            color: Colors.white,
            iconSize: 30,
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              // do something when the button is pressed
              Navigator.pushReplacementNamed(context, homescreen.home);
            },
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.01),
              child: ElevatedButton(
                onPressed: () async {
                  await deleteOrder();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Delete Product',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.01,
                  left: screenWidth * 0.1,
                  right: screenWidth * 0.1,
                ),
                child: Text(
                  "Product Details",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.02,
                  left: screenWidth * 0.3,
                  right: screenWidth * 0.3,
                ),
                child: textfield(
                  controller: pnameController,
                  hintText: pnameController.text,
                  label: 'Product Name',
                  keyboardtype: 'text',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.01,
                  left: screenWidth * 0.3,
                  right: screenWidth * 0.3,
                ),
                child: textfield(
                  controller: cnameController,
                  hintText: cnameController.text,
                  label: 'Customer Name',
                  keyboardtype: 'text',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.01,
                  left: screenWidth * 0.3,
                  right: screenWidth * 0.3,
                ),
                child: textfield(
                  controller: phoneController,
                  hintText: phoneController.text,
                  label: 'Phone',
                  keyboardtype: 'phone',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.01,
                  left: screenWidth * 0.3,
                  right: screenWidth * 0.3,
                ),
                child: textfield(
                  controller: addressController,
                  hintText: addressController.text,
                  label: 'Address',
                  keyboardtype: 'text',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.01,
                  left: screenWidth * 0.3,
                  right: screenWidth * 0.3,
                ),
                child: textfield(
                  controller: postController,
                  hintText: postController.text,
                  label: 'Post Code',
                  keyboardtype: 'number',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.01,
                  left: screenWidth * 0.3,
                  right: screenWidth * 0.3,
                ),
                child: TextField(
                  controller: trackingid,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white54,
                    hintText: trackingid.text,
                    labelText: 'Tracking Id',
                    contentPadding: EdgeInsets.all(screenWidth*0.01),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                )
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.01,
                  left: screenWidth * 0.3,
                  right: screenWidth * 0.3,
                ),
                child: textfield(
                  controller: variationsController,
                  hintText: variationsController.text,
                  label: 'Variations',
                  keyboardtype: 'text',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.01,
                  left: screenWidth * 0.3,
                  right: screenWidth * 0.3,
                ),
                child: textfield1(
                  controller: serviceController,
                  hintText: serviceController.text,
                  label: 'From Service',
                  keyboardtype: 'text',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: screenWidth * 0.02,
                    left: screenWidth * 0.09,
                    right: screenWidth * 0.09),
                child: SizedBox(
                  width: screenWidth * 0.4,
                  child: ElevatedButton(
                    onPressed: () {
                      if (pnameController.text.isEmpty ||
                          cnameController.text.isEmpty ||
                          phoneController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          postController.text.isEmpty||
                      variationsController.text.isEmpty) {
                        AwesomeDialog(context: context,
                            width: screenWidth*0.3,
                            dialogType: DialogType.error,
                            animType: AnimType.topSlide,
                            enableEnterKey: true,
                            title: 'Error',
                            desc: 'Please fill all fields',
                            btnOkOnPress: (){
                              Navigator.pushReplacementNamed(context, product.productpage);
                            }).show();
                      } else {
                        updateUserData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                          color: Colors.white, fontSize: screenWidth * 0.017),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _loading,
                child: Container(
                  color:
                      Colors.black.withOpacity(0.5), // Adjust opacity as needed
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(customColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
