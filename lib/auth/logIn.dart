import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eaziprep_app_desktop/auth/AuthService.dart';
import '../welcomeScreen.dart';
import 'package:flutter/material.dart';
import '../services.dart';


class login extends StatefulWidget {
  static const signin = "/signin";

  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  bool _loading = false;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    Color customColor = HexColor("#fd7b2e");

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(
            context, welcomescreen.welcome);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
              AssetImage('assets/login.png'), // Replace with your image asset
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: _loading,
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
                  child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(customColor),),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: screenWidth*0, right: screenWidth*0.95),
                child: IconButton(
                  color: Colors.white,
                  iconSize: 50,
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () {
                    // do something when the button is pressed
                    Navigator.pushReplacementNamed(context, welcomescreen.welcome);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: screenWidth*0.03,right: screenWidth*0.1,top: screenWidth*0.05),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.getFont(
                    'Outfit',
                    textStyle: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0, left: screenWidth * 0.03, right: screenWidth * 0.1),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth*0.3),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: email,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(fontSize: screenWidth*0.01),
                      contentPadding:  EdgeInsets.only(left:screenWidth*0.01),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.white38,
                    ),
                    onChanged: (value) {
                      // do something
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.01, left: screenWidth * 0.03, right: screenWidth * 0.1),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth*0.3),
                  child: TextField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: password,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(fontSize: screenWidth*0.01),
                      contentPadding:  EdgeInsets.only(left:screenWidth*0.01),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.white38,
                    ),
                    onChanged: (value) {
                      // do something
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.03, left: screenWidth * 0.37, right: screenWidth * 0.45),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      loginUser(email.text.trim(), password.text); // Use the instance to call loginUser
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(color: customColor,fontSize: screenWidth*0.016),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),);
  }
  Future<void> loginUser(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      showToast("Please fill all fields.");
      return;
    }
    setState(() {
      _loading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      AuthService.setLoginStatus();
      setState(() {
        _loading = false;
      });
      Navigator.pushReplacementNamed(context, services.service);
    } on FirebaseAuthException catch (e) {
      print("Error logging in: $e");
      showToast("Error logging in. Please try again.");
    }
  }
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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