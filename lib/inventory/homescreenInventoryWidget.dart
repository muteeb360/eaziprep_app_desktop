import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eaziprep_app_desktop/inventory/inventory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/logIn.dart';
import '../homescreen/homescreenhelper.dart';

class homescreenInventoryWidget extends StatefulWidget {
  const homescreenInventoryWidget({super.key});

  @override
  State<homescreenInventoryWidget> createState() =>
      _homescreenInventoryWidgetState();
}

class _homescreenInventoryWidgetState extends State<homescreenInventoryWidget> {
  late String totalproducts='';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
            totalproducts = userSnapshot['Total Products'];
          });
        } else {
          print("User document does not exist");
        }
        print("fetched data of company name and services");

      } catch (e) {
        print("Error fetching data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color customColor = HexColor("#fd7b2e");
    return Padding(
      padding: EdgeInsets.only(
        top: screenHeight * 0.03,
        left: screenWidth * 0.6,
      ),
      child: Container(
        width: screenWidth * 0.3,
        height: screenHeight * 0.23,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0), // Adjust the radius as needed
          ),
          color: Colors.white70,
        ),
        child: Card(
          color: customColor,
          child: Container(
            width: screenWidth * 0.18,
            child: Column(
              children: [
                Center(
                  child: Container(
                    child:
                    Text('Inventory',style: GoogleFonts.getFont(
                      'Outfit',
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.02,
                        color: Colors.white,
                      ),
                    ),),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth*0.01,left: screenWidth*0.01),
                      child: Expanded(
                        child: Text(
                          'Total Products: $totalproducts',
                          style: GoogleFonts.getFont(
                            'Outfit',
                            textStyle: TextStyle(
                              fontSize: screenWidth * 0.015,
                              color: Colors.white,
                            ),
                          ),
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth*0.01),
                      child: Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, inventory.userinventory);
                            },
                            child: Text(
                              'update inventory',
                              style: GoogleFonts.getFont(
                                'Outfit',
                                textStyle: TextStyle(
                                  fontSize: screenWidth * 0.015,
                                  color: Colors.yellow,
                                ),
                              ),
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
