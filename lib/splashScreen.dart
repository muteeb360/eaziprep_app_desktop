import 'dart:async';
import 'package:eaziprep_app_desktop/addorders/addorder.dart';
import 'package:eaziprep_app_desktop/auth/logIn.dart';
import 'package:eaziprep_app_desktop/helpers/test.dart';
import 'package:eaziprep_app_desktop/homescreen/homescreenservices.dart';
import 'package:eaziprep_app_desktop/inventory/inventory.dart';
import 'package:eaziprep_app_desktop/inventory/inventoryProduct.dart';

import 'homescreen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcomeScreen.dart';

class splashScreen extends StatefulWidget {
  static const String route = './splashscreen';

  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  late SharedPreferences _prefs;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _navigateToScreen();
  }

  Future<void> _checkLoginStatus() async {
    _prefs = await SharedPreferences.getInstance();
    _isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;


      if (_isLoggedIn) {
        // User is logged in, navigate to the home screen
         Navigator.pushReplacementNamed(context, addorder.add);
        //Navigator.pushReplacementNamed(context, homescreen.home);
      }else {
        Navigator.pushReplacementNamed(context,welcomescreen.welcome);
        print('user is not logged in');
      }
  }

  _navigateToScreen() async {
    // Add a delay for splash screen visibility
    await Future.delayed(const Duration(milliseconds: 2000), () { _checkLoginStatus();});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 200.0,vertical: 200),
          child: Container(
            child: const Image(
              image: AssetImage('assets/logo.png'),
            ),
          ),
        ),
      ),
    );
  }
}
