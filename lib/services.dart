import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen/homescreen.dart';
import 'auth/logIn.dart';
import 'package:flutter/material.dart';


class services extends StatefulWidget {
  static const service = './services';

  const services({super.key});

  @override
  State<services> createState() => _servicesState();
}

class _servicesState extends State<services> {
  bool _loading = false;
  List<bool> selectedCardIndices = [false, false, false, false, false, false];
  List<String> serviceTitles = [
    'FBM Services',
    'Tik Tok Fulfilment',
    'Ebay Fulfilment',
    'FBA Services',
    'Etsy Fulfilment',
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Color customColor = HexColor("#fd7b2e");
    return  WillPopScope(
        onWillPop: () async {
      Navigator.pushReplacementNamed(
          context, login.signin);
      return true;
    },
    child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/services.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: screenWidth * 0.01, right: screenWidth * 0.95),
              child: IconButton(
                color: Colors.black,
                iconSize: 50,
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {
                    Navigator.pushReplacementNamed(context,login.signin);
                },
              ),
            ),
          ),

          Column(
            children: [

              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.092, right: screenWidth * 0.3),
                child: buildCard('FPM Services', screenWidth, 0),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.01, right: screenWidth * 0.3),
                child: buildCard('Tik Tok Fulfilment', screenWidth, 1),
              ),

              Padding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.04,
                  right: screenWidth * 0.2,
                  left: screenWidth * 0.2,
                ),
                child: SizedBox(
                  width: screenWidth*0.3,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Check if at least one service is selected
                      if (!selectedCardIndices.contains(true)) {
                        showToast("Please select at least one service.");
                        return;
                      }

                      // Extract and save selected services to Firestore
                      await saveSelectedServices();

                      // Navigate to the home screen
                      Navigator.pushReplacementNamed(context, homescreen.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Finish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.02,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.092, left: screenWidth * 0.01),
                child: buildCard('Amazon Fulfilment', screenWidth, 3),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.01, left: screenWidth * 0.01),
                child: buildCard('Etsy Fulfilment', screenWidth, 4),
              ),

            ],
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.092, left: screenWidth * 0.3),
                child: buildCard('Ebay Fulfilment', screenWidth, 2),
              ),

            ],
          ),
          Visibility(
            visible: _loading,
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(customColor),),
              ),
            ),
          ),
        ],

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

  Widget buildCard(String title,double screenWidth, int index) {
    Color customColor = HexColor("#fd7b2e");
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCardIndices[index] = !selectedCardIndices[index];
          });
        },
        child: SizedBox(
          height: screenWidth*0.13,
          width: screenWidth*0.13,

          child: Card(
            color: selectedCardIndices[index] ? customColor : Colors.white70,
            child: Center(
              child: ListTile(
                title: Text(
                  title,
                  textAlign: TextAlign.center,

                  style: GoogleFonts.getFont(
                    'Outfit',
                    textStyle: TextStyle(
                      fontSize: screenWidth*0.015,
                      color: selectedCardIndices[index] ? Colors.white : Colors.black38,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveSelectedServices() async {
    setState(() {
      _loading = true;
    });
    try {
      // Get the user's email from the login screen or wherever you store it
      String userEmail = await getUserEmail(); // Replace with actual user email retrieval logic

      // Extract selected services
      List<String> selectedServices = [];
      for (int i = 0; i < selectedCardIndices.length; i++) {
        if (selectedCardIndices[i]) {
          selectedServices.add(serviceTitles[i]);
        }
      }

      // createEmptySubcollections(userEmail,selectedServices);

      // Add selected services to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userEmail).update({
        'selectedServices': selectedServices,
        // Add more fields as needed
      });
      setState(() {
        _loading = false;
      });
    } catch (e) {
      print("Error saving services: $e");
      // Handle errors
    }
  }

  Future<String> getUserEmail() async {
    return FirebaseAuth.instance.currentUser?.email ?? '';
  }

  // Future<void> createEmptySubcollections(String userEmail, List<String> selectedServices) async {
  //   // Reference to the Firestore instance
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //
  //   // Reference to the 'users' collection
  //   CollectionReference usersCollection = firestore.collection('users');
  //
  //   try {
  //     // Reference to the user's document using their email
  //     DocumentReference userDocument = usersCollection.doc(userEmail);
  //
  //     // Iterate through the selected services and create empty subcollections
  //     for (String service in selectedServices) {
  //       // Create an empty subcollection within the user's document for each service
  //       await userDocument.collection(service).doc().set(Map<String, dynamic>());
  //       print('Empty subcollection for $service created successfully.');
  //     }
  //   } catch (e) {
  //     print('Error creating empty subcollections: $e');
  //   }
  // }

}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }
}
