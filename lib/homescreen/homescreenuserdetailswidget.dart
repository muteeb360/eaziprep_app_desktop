import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eaziprep_app_desktop/homescreen/homescreenhelper.dart';
import 'package:eaziprep_app_desktop/auth/logIn.dart';

class homescreenuserdetailswidget extends StatefulWidget {
  const homescreenuserdetailswidget({super.key});

  @override
  State<homescreenuserdetailswidget> createState() => _homescreenuserdetailswidgetState();
}

class _homescreenuserdetailswidgetState extends State<homescreenuserdetailswidget> {
  late Map<String, dynamic>? userData;
  late String? userEmail;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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

    // Trigger a rebuild after data is initialized
    if (mounted) {
      setState(() {});
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color customColor = HexColor("#fd7b2e");
    return isLoading
        ? Center(
      child: CircularProgressIndicator(),
    )
        : Padding(
      padding: EdgeInsets.only(top: screenHeight*0.03,left: screenWidth * 0.1,),
      child: Container(
        width: screenWidth*0.3,
        height: screenHeight*0.23,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0), // Adjust the radius as needed
          ),
          color: Colors.white70,
        ),
        child: Card(
          color: customColor,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: screenWidth *
                            0.01,
                        top: screenHeight *
                            0.02),
                    child: CircleAvatar(
                      radius: screenWidth *
                          0.05,
                      backgroundImage:NetworkImage(userData?['imageUrl']),
                    ),
                  ),
                  Container(
                    width:
                    screenWidth *
                        0.18,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child:
                              Text(
                                'Name: ${userData?['name']}',
                                style:
                                GoogleFonts.getFont(
                                  'Outfit',
                                  textStyle:
                                  TextStyle(
                                    fontSize: screenWidth * 0.015,
                                    color: Colors.white,
                                  ),
                                ),
                                softWrap:
                                false,
                                maxLines:
                                1,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child:
                              Text(
                                'Company: ${userData?['company_name']}',
                                style:
                                GoogleFonts.getFont(
                                  'Outfit',
                                  textStyle:
                                  TextStyle(
                                    fontSize: screenWidth * 0.015,
                                    color: Colors.white,
                                  ),
                                ),
                                softWrap:
                                false,
                                maxLines:
                                1,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child:
                              Text(
                                'Phone: ${userData?['phone']}',
                                style:
                                GoogleFonts.getFont(
                                  'Outfit',
                                  textStyle:
                                  TextStyle(
                                    fontSize: screenWidth * 0.015,
                                    color: Colors.white,
                                  ),
                                ),
                                softWrap:
                                false,
                                maxLines:
                                1,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: MouseRegion(
                        //         cursor: SystemMouseCursors.click,
                        //         child: GestureDetector(
                        //           onTap: () {
                        //             // Navigate to the other screen
                        //             // Navigator.push(context, MaterialPageRoute(builder: (context) => OtherScreen()));
                        //           },
                        //           child: Text(
                        //             'view details',
                        //             style: GoogleFonts.getFont(
                        //               'Outfit',
                        //               textStyle: TextStyle(
                        //                 fontSize: screenWidth * 0.015,
                        //                 color: Colors.yellow,
                        //               ),
                        //             ),
                        //             softWrap: false,
                        //             maxLines: 1,
                        //             overflow: TextOverflow.ellipsis,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
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
  }
}
