import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eaziprep_app_desktop/homescreen/homescreen.dart';
import 'package:eaziprep_app_desktop/inventory/inventoryProduct.dart';
import 'package:eaziprep_app_desktop/inventory/inventoryProductDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/logIn.dart';
import '../helpers/DropDownHelper.dart';
import '../homescreen/homescreenhelper.dart';

class inventory extends StatefulWidget {
  static const userinventory = './inventory';
  const inventory({super.key});

  @override
  State<inventory> createState() => _inventoryState();
}

class _inventoryState extends State<inventory> {

  late Map<String, dynamic>? userData;
  late String? userEmail;
  late List<String> userservices=[];
  String collectionname='';
  bool isLoading = false;


  @override
  void initState(){
    super.initState();
    print('initState called!');
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });
    // Use FirebaseAuth to get the current user's email
    userEmail = FirebaseAuth.instance.currentUser?.email;

    // Get user data
    userData = await getUserData(userEmail!);
    userservices = userData?['services'];
    collectionname=userservices[0];
    print('collection name : $collectionname');
    print('services $userservices');

    // Trigger a rebuild after data is initialized
    if (mounted) {
      setState(() {});
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16.0),
              Text("Loading..."),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> getDataStream(String collectionname) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection(collectionname)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color customColor = HexColor("#fd7b2e");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: customColor,
        title: const Text(
          'Inventory',
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
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: screenHeight*0.1),
              width: screenWidth*0.8,
                child: DropDownHelper1(
              services: userservices,
              onServiceSelected: (selectedValue) {
                setState(() {
                  collectionname = selectedValue;
                });
              },
            )),
            Padding(
              padding: EdgeInsets.only(
                  top: screenWidth * 0.03,
                  left: screenWidth * 0.1,
                  right: screenWidth * 0.1),
              child: Container(
                height: screenWidth * 0.37,
                width: screenWidth * 0.8,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft:
                        Radius.circular(20.0), // Adjust the radius as needed
                    topRight:
                        Radius.circular(20.0), // Adjust the radius as needed
                  ),
                  color: Colors.black45,
                ),
                child: Column(
                  children: [
                    Builder(
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Products',
                                      style: GoogleFonts.getFont(
                                        'Outfit',
                                        textStyle: TextStyle(
                                          fontSize: screenWidth * 0.02,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        color: Colors.white
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: screenWidth * 0.6),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const inventoryProduct(),
                                              settings: RouteSettings(
                                                arguments: {
                                                  'service': collectionname,
                                                },
                                              ),
                                              // Add more data variables as needed
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        child: const Text(
                                          'Add Product',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: screenHeight * 0.586,
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: getDataStream(collectionname),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }

                                      final List<DocumentSnapshot> shopDocs =
                                          snapshot.data!.docs;

                                      if (shopDocs.isEmpty) {
                                        return const Text('no products available in this inventory');
                                      }

                                      return ListView.builder(
                                        itemCount: shopDocs.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final shopData = shopDocs[index]
                                              .data() as Map<String, dynamic>;
                                          final List<dynamic> imageUrl =
                                              shopData['imageUrls'];
                                          final pname = shopData['pname'];
                                          final variations = shopData['variations'];
                                          final stock = shopData['stock'];

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => inventoryProductDetails(
                                                    pname: pname,
                                                    collection:collectionname
                                                    // Add more data variables as needed
                                                  ),
                                                ),
                                              );
                                            },
                                            child: SizedBox(
                                              height: screenHeight * 0.16,
                                              child: Card(
                                                color: customColor,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                              left:
                                                                  screenWidth *
                                                                      0.03,
                                                              top:
                                                                  screenHeight *
                                                                      0.02),
                                                          child: CircleAvatar(
                                                            radius:
                                                                screenWidth *
                                                                    0.03,
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    imageUrl
                                                                        .first),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets.only(
                                                                    right: 0,
                                                                    left:
                                                                        screenWidth *
                                                                            0.05,
                                                                    bottom:
                                                                        screenHeight *
                                                                            0.0),
                                                                width:
                                                                    screenWidth *
                                                                        0.45,
                                                                child: Text(
                                                                  '$pname',
                                                                  style: GoogleFonts
                                                                      .getFont(
                                                                    'Outfit',
                                                                    textStyle:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          screenWidth *
                                                                              0.02,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets.only(
                                                                    left: screenWidth *
                                                                        0.05),
                                                                width:
                                                                    screenWidth *
                                                                        0.45,
                                                                child: Text(
                                                                  'Stock: $stock',
                                                                  style: GoogleFonts
                                                                      .getFont(
                                                                    'Outfit',
                                                                    textStyle:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          screenWidth *
                                                                              0.01,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets.only(
                                                                    left: screenWidth *
                                                                        0.05),
                                                                width:
                                                                screenWidth *
                                                                    0.45,
                                                                child: Text(
                                                                  'Variations: $variations',
                                                                  style: GoogleFonts
                                                                      .getFont(
                                                                    'Outfit',
                                                                    textStyle:
                                                                    TextStyle(
                                                                      fontSize:
                                                                      screenWidth *
                                                                          0.01,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
