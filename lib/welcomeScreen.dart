import 'package:google_fonts/google_fonts.dart';

import 'auth/signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'auth/logIn.dart';
import 'package:carousel_slider/carousel_slider.dart';

class welcomescreen extends StatefulWidget {
  static const welcome = '/welcomeScreen';

  const welcomescreen({super.key});

  @override
  State<welcomescreen> createState() => _welcomescreenState();
}

class _welcomescreenState extends State<welcomescreen> {
  final CarouselController carouselController = CarouselController();
  int currentindex = 0;
  List<Widget> image = [
    Image.asset('assets/4.png'),
    Image.asset('assets/5.png'),
    Image.asset('assets/6.png'),
    Image.asset('assets/7.png'),
    Image.asset('assets/8.png'),
  ];
  @override
  Widget build(BuildContext context) {
    Color customColor = HexColor("#fd7b2e");
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/getstarted.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LODGEX',
              style: GoogleFonts.getFont(
                'Oswald',
                textStyle: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: customColor
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top:screenWidth*0.05),
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {},
                    child: CarouselSlider(
                      items: image.map((Widget item) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.1,
                          ),
                          child: item,
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: screenHeight * 0.4,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        onPageChanged: (index, reason) {
                          // do something when the page changes
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                  top: screenHeight*0.05,
                    bottom: screenWidth * 0.01,
                    left: screenWidth * 0.4,
                    right: screenWidth * 0.4),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, login.signin);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.02,
                  right: screenWidth * 0.02),
              child: RichText(
                text: TextSpan(
                  text: 'If no account yet, ',
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Register here',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacementNamed(
                              context, signup.register );
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
