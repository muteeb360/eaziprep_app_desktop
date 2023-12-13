import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../homescreen/homescreen.dart';

class test extends StatelessWidget {
  static const test1 = './test';
  const test({super.key});


  @override
  Widget build(BuildContext context) {
    void _showDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Your Dialog Title'),
            content: Text('Your dialog content goes here.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Perform an action when the user selects OK
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    return Scaffold(
      body: ElevatedButton(onPressed: (){_showDialog();}, child: Text('Homescreen')),
    );
  }
}
