import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:eaziprep_app_desktop/helpers/producttextfield.dart'; // Assuming this contains your custom TextField widget
import 'package:eaziprep_app_desktop/auth/logIn.dart';
import 'inventory.dart';

class inventoryProductDetails extends StatefulWidget {
  static const productpagedetails = '/productdetails';
  String pname = '';
  String collection='';
  inventoryProductDetails({
    super.key,
    required this.pname,
    required this.collection
  });

  @override
  State<inventoryProductDetails> createState() => _inventoryProductDetailsState();
}

class _inventoryProductDetailsState extends State<inventoryProductDetails> {
  bool _loading = false;
  TextEditingController pnameController = TextEditingController();
  TextEditingController variationController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  late String totalproducts='';
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
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userEmail);
      DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        // Get the company name and selected services
        setState(() {
          totalproducts = userSnapshot['Total Products'];
        });
      } else {
        print("User document does not exist");
      }
      print('total : $totalproducts');
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userEmail)
          .get();

      if (userDoc.exists) {

        // Assuming subcollection 'orders' and document 'pname' exist
        DocumentSnapshot<Map<String, dynamic>> orderDoc = await userDoc
            .reference
            .collection(widget.collection)
            .doc(widget.pname)
            .get();

        if (orderDoc.exists) {
          Map<String, dynamic> orderData = orderDoc.data() ?? {};

          setState(() {
            pnameController.text = orderData['pname'] ?? '';
            variationController.text = orderData['variations'] ?? '';
            stockController.text = orderData['stock'] ?? '';
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
          .collection(widget.collection)
          .doc(widget.pname);

      await orderDocReference.set({
        'pname': pnameController.text,
        'variations': variationController.text,
        'stock': stockController.text,
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
      Navigator.pushReplacementNamed(context, inventory.userinventory);
    }
  }

  Future<void> deleteOrder() async {
    try {

      String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      int total = int.parse(totalproducts);
      total = total -1;
      totalproducts = total.toString();
      // Get a reference to the document to be deleted
      DocumentReference productDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail);
      await productDocRef.update({
        'Total Products': totalproducts,
      });
      DocumentReference orderDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection(widget.collection)
          .doc(pnameController.text);

      DocumentReference totalproductsDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('allproducts')
          .doc(pnameController.text);

      // Delete the document
      await orderDocRef.delete();
      await totalproductsDocRef.delete();

      print('Document deleted successfully');
      Navigator.pushReplacementNamed(context,inventory.userinventory);
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
        Navigator.pushReplacementNamed(context, inventory.userinventory);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: customColor,
          title: const Text(
            'Product Details',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            color: Colors.white,
            iconSize: 30,
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              // do something when the button is pressed
              Navigator.pushReplacementNamed(context, inventory.userinventory);
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
                  top: screenHeight * 0.1,
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
                  controller: variationController,
                  hintText: variationController.text,
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
                child: textfield(
                  controller: stockController,
                  hintText: stockController.text,
                  label: 'Stock',
                  keyboardtype: 'number',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: screenWidth * 0.03,
                    left: screenWidth * 0.09,
                    right: screenWidth * 0.09),
                child: SizedBox(
                  width: screenWidth * 0.4,
                  child: ElevatedButton(
                    onPressed: () {
                      if (pnameController.text.isEmpty ||
                          variationController.text.isEmpty ||
                          stockController.text.isEmpty) {
                        showToast("Please fill all fields.");
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
