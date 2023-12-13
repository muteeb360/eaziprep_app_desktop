import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eaziprep_app_desktop/inventory/homescreenInventoryWidget.dart';
import 'package:eaziprep_app_desktop/homescreen/homescreenuserdetailswidget.dart';
import '../helpers/drawer.dart';
import '../product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../addorders/addorder.dart';
import 'package:flutter/material.dart';
import '../auth/logIn.dart';

class homescreen extends StatefulWidget {
  static const home = '/homescreen';

  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  List<Map<String, dynamic>> orders = [];
  late String? userEmail;
  late Color customColor;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    // Use FirebaseAuth to get the current user's email
    userEmail = FirebaseAuth.instance.currentUser?.email;

    // Trigger a rebuild after data is initialized
    if (mounted) {
      setState(() {});
    }
  }



  Stream<QuerySnapshot> getDataStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('orders')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color customColor = HexColor("#fd7b2e");
    Color color = HexColor("#fd7b2e");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: customColor,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the color to white
        ),
      ),
      drawer: const drawer(),
      body: Stack(
        // fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/home.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          homescreenuserdetailswidget(),
          homescreenInventoryWidget(),
          Padding(
            padding: EdgeInsets.only(
                top: screenWidth * 0.15,
                left: screenWidth * 0.1,
                right: screenWidth * 0.1),
            child: Container(
              height: screenWidth * 0.35,
              width: screenWidth * 0.8,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0), // Adjust the radius as needed
                  topRight:
                      Radius.circular(20.0), // Adjust the radius as needed
                ),
                color: Colors.white70,
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
                                    'Orders',
                                    style: GoogleFonts.getFont(
                                      'Outfit',
                                      textStyle: TextStyle(
                                        fontSize: screenWidth * 0.02,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: screenHeight * 0.586,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: getDataStream(),
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
                                      return const Text('No Orders made yet');
                                    }

                                    return ListView.builder(
                                      itemCount: shopDocs.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final shopData = shopDocs[index].data()
                                            as Map<String, dynamic>;
                                        final List<dynamic> imageUrl =
                                            shopData['imageUrls'];
                                        final id = shopData['id'];
                                        final pname = shopData['pname'];
                                        final cname = shopData['cname'];
                                        final status = shopData['status'];
                                        final tid = shopData['tid'];
                                        color = HexColor(shopData['color']);

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => product(
                                                  pname: pname,
                                                  id: id,
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
                                                            left: screenWidth *
                                                                0.03,
                                                            top: screenHeight *
                                                                0.02),
                                                        child: CircleAvatar(
                                                          radius: screenWidth *
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
                                                                style:
                                                                    GoogleFonts
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
                                                                  left:
                                                                      screenWidth *
                                                                          0.05),
                                                              width:
                                                                  screenWidth *
                                                                      0.45,
                                                              child: Text(
                                                                '$cname',
                                                                style:
                                                                    GoogleFonts
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
                                                                  left:
                                                                      screenWidth *
                                                                          0.05),
                                                              width:
                                                                  screenWidth *
                                                                      0.45,
                                                              child: Text(
                                                                'Status : $status',
                                                                style:
                                                                    GoogleFonts
                                                                        .getFont(
                                                                  'Outfit',
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.01,
                                                                    color:
                                                                        color,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets.only(
                                                                  left:
                                                                      screenWidth *
                                                                          0.05),
                                                              width:
                                                                  screenWidth *
                                                                      0.45,
                                                              child: Text(
                                                                'Tracking Id : $tid',
                                                                style:
                                                                    GoogleFonts
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, addorder.add);
        },
        backgroundColor: customColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
