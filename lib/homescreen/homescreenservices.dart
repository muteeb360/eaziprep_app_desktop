import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eaziprep_app_desktop/homescreen/homescreen.dart';
import 'package:eaziprep_app_desktop/auth/logIn.dart';
import 'package:flutter/material.dart';


class homescreenservices extends StatefulWidget {
  static const service = './homescreenservices';

  const homescreenservices({super.key});

  @override
  State<homescreenservices> createState() => _homescreenservicesState();
}

class _homescreenservicesState extends State<homescreenservices> {
  bool _loading = false;
  List<bool> selectedCardIndices = [false, false, false, false, false, false];
  List<String> previousselectedservices =[];
  List<String> serviceTitles = [
    'FBM Services',
    'Tik Tok Fulfilment',
    'Ebay Fulfilment',
    'FBA Services',
    'Etsy Fulfilment',
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void updateSelectedCardIndices() {
    for (int i = 0; i < serviceTitles.length; i++) {
      if (previousselectedservices.contains(serviceTitles[i])) {
        selectedCardIndices[i] = true;
      }
    }
  }

  Future<void> fetchData() async {
    print('inside fetchdata');
    setState(() {
      _loading = true;
    });
    FirebaseAuth.instance.authStateChanges().listen((User? user) async{
      if (user != null) {
        // Get the user's email
        String userEmail = await getUserEmail();
        // Reference to the user's document in the "users" collection
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userEmail);
        // Fetch data from Firestore
        try {
          DocumentSnapshot userSnapshot = await userRef.get();
          // Check if the document exists
          if (userSnapshot.exists) {
            // Get the company name and selected services
            setState(() {
              previousselectedservices = List<String>.from(userSnapshot['selectedServices']);
            });
          } else {
            print("User document does not exist");
          }
          updateSelectedCardIndices();
        } catch (e) {
          print("Error fetching data: $e");
        }} else {
        print('user is null');
      }
    });
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Color customColor = HexColor("#fd7b2e");
    return  WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(
            context, homescreen.home);
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
                    Navigator.pushReplacementNamed(context,homescreen.home);
                  },
                ),
              ),
            ),

            Column(
              children: [

                Padding(
                  padding: EdgeInsets.only(top: screenWidth * 0.092, right: screenWidth * 0.3),
                  child: buildCard('FBM Services', screenWidth, 0),
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
                  child: buildCard('FBA Services', screenWidth, 3),
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
      String fbm='',fba='',etsy='',ebay='',tiktok='';

      // Get the user's email from the login screen or wherever you store it
      String userEmail = await getUserEmail(); // Replace with actual user email retrieval logic
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc('FBM Services');
      DocumentSnapshot userSnapshot = await userRef.get();
      DocumentReference userRef1 = FirebaseFirestore.instance.collection('users').doc('FBA Services');
      DocumentSnapshot userSnapshot1 = await userRef1.get();
      DocumentReference userRef2 = FirebaseFirestore.instance.collection('users').doc('Etsy Fulfilment');
      DocumentSnapshot userSnapshot2 = await userRef2.get();
      DocumentReference userRef3 = FirebaseFirestore.instance.collection('users').doc('Ebay Fulfilment');
      DocumentSnapshot userSnapshot3 = await userRef3.get();
      DocumentReference userRef4 = FirebaseFirestore.instance.collection('users').doc('Tik Tok Fulfilment');
      DocumentSnapshot userSnapshot4 = await userRef4.get();

      // Get the company name and selected services
      setState(() {
        fbm = userSnapshot['clients'];
        fba = userSnapshot1['clients'];
        etsy = userSnapshot2['clients'];
        ebay = userSnapshot3['clients'];
        tiktok = userSnapshot4['clients'];
      });
      int fbm1=int.parse(fbm),fba1=int.parse(fba),etsy1=int.parse(etsy),ebay1=int.parse(ebay),tiktok1=int.parse(tiktok);
      // Extract selected services
      List<String> nowselectedServices = [];
      for (int i = 0; i < selectedCardIndices.length; i++) {
        if (selectedCardIndices[i]) {
          nowselectedServices.add(serviceTitles[i]);
        }
      }

      for (int i = 0; i < nowselectedServices.length; i++) {
        if(nowselectedServices[i]=='FBM Services'){
          fbm1 +=1;
          fbm = fbm1.toString();
          await FirebaseFirestore.instance.collection('users').doc('FBM Services').update({
            'clients': fbm,
            'emails': userEmail
            // Add more fields as needed
          });
        }else if(nowselectedServices[i]=='FBA Services'){
          fba1 +=1;
          fba = fba1.toString();
          await FirebaseFirestore.instance.collection('users').doc('FBA Services').update({
            'clients': fba,
            'emails': userEmail
            // Add more fields as needed
          });
        }else if(nowselectedServices[i]=='Etsy Fulfilment'){
          etsy1 +=1;
          etsy = etsy1.toString();
          await FirebaseFirestore.instance.collection('users').doc('Etsy Fulfilment').update({
            'clients': etsy,
            'emails': userEmail
            // Add more fields as needed
          });
        }else if(nowselectedServices[i]=='Ebay Fulfilment'){
          ebay1 +=1;
          ebay = ebay1.toString();
          await FirebaseFirestore.instance.collection('users').doc('Ebay Fulfilment').update({
            'clients': ebay,
            'emails': userEmail
            // Add more fields as needed
          });
        }else if(nowselectedServices[i]=='Tik Tok Fulfilment'){
          tiktok1 +=1;
          tiktok = tiktok1.toString();
          await FirebaseFirestore.instance.collection('users').doc('Tik Tok Fulfilment').update({
            'clients': tiktok,
            'emails': userEmail
            // Add more fields as needed
          });
        }
      }
      // Add selected services to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userEmail).update({
        'selectedServices': nowselectedServices,
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
