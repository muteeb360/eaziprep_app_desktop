import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'inventory.dart';
import 'package:flutter/material.dart';
import '../helpers/textfield.dart';
import '../auth/logIn.dart';
import 'inventoryProduct2.dart';

class inventoryProduct extends StatefulWidget {
  static const addinventory = '/inproduct';

  const inventoryProduct({super.key});

  @override
  State<inventoryProduct> createState() => _inventoryProductState();
}

class _inventoryProductState extends State<inventoryProduct> {
  final TextEditingController product = TextEditingController();
  final TextEditingController variations = TextEditingController();
  final TextEditingController stock = TextEditingController();
  String collection = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String companyName = "";
  List<String> selectedServices = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Get the current user
    User? user = _auth.currentUser;

    if (user != null) {
      // Get the user's email
      String userEmail = user.email!;

      // Reference to the user's document in the "users" collection
      DocumentReference userRef = _firestore.collection('users').doc(userEmail);

      // Fetch data from Firestore
      try {
        DocumentSnapshot userSnapshot = await userRef.get();

        // Check if the document exists
        if (userSnapshot.exists) {
          // Get the company name and selected services
          setState(() {
            companyName = userSnapshot['company_name'];
            selectedServices = List<String>.from(userSnapshot['selectedServices']);
          });
        } else {
          print("User document does not exist");
        }

      } catch (e) {
        print("Error fetching data: $e");
      }
    }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the passed data in the initState or didChangeDependencies
    final Map<String, dynamic>? arguments =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      collection = arguments['service'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Color customColor = HexColor("#fd7b2e");
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: customColor,
          title: const Text('Inventory Product',style: TextStyle(color: Colors.white),),
          leading:
          IconButton(
            color: Colors.white,
            iconSize: 30,
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              // do something when the button is pressed
              Navigator.pushReplacementNamed(context, inventory.userinventory);
            },
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/home.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: screenWidth*0.03,
                  top: screenWidth * 0.03,
                  left: screenWidth * 0.2,
                  right: screenWidth * 0.2),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  color: Colors.white54,
                ),
                child: SingleChildScrollView(
                  child:  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenWidth * 0.06),
                        child: Text(
                          'Add Product Details',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.02,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: textfield(
                            controller: product, hintText: 'Product Name',keyboardtype: 'text'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.02,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: textfield(
                            controller: variations, hintText: 'Variations',keyboardtype: 'text'),
                      ),
                      Row(
                        children: [
                          SizedBox(width: screenWidth*0.15,),
                          Icon(Icons.info_rounded,size: screenWidth*0.02,),
                          Container(
                            width: screenWidth*0.3,
                            child: Text(' Add variations of product if have any or leave this empty(use commas to separate)',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black
                            ),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.02,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: textfield(
                            controller: stock, hintText: 'Stock',keyboardtype: 'number'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.02,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (product.text.isEmpty) {
                                showToast("Please fill all fields.");
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const inventoryProduct2(),
                                    settings: RouteSettings(
                                      arguments: {
                                        'pname': product.text,
                                        'variations': variations.text,
                                        'stock': stock.text,
                                        'service':collection
                                      },
                                    ),
                                    // Add more data variables as needed
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
