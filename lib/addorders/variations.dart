import 'package:flutter/material.dart';
import 'addorder2.dart';
import '../auth/logIn.dart';

class YourDialog extends StatefulWidget {
  List<String> variations = [];
  String pname = '',
      cname = '',
      service = '',
      phone = '',
      post = '',
      address = '',
      cemail = '',
      company = '';
  YourDialog(
      {required this.variations,
      required this.pname,
      required this.cname,
      required this.service,
      required this.cemail,
      required this.address,
      required this.phone,
      required this.post,
      required this.company});
  @override
  _YourDialogState createState() => _YourDialogState();
}

class _YourDialogState extends State<YourDialog> {
  // Your checkbox state and other variables
  Map<String, bool> checkboxState = {};
  Map<String, TextEditingController> textEditingControllerMap = {};
  List<String> finalvariation = [],finalvalues=[];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each variation
    for (String variation in widget.variations) {
      textEditingControllerMap[variation] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> variations = widget.variations;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color customColor = HexColor("#fd7b2e");
    return AlertDialog(
      title: Text('Add quantity'),
      content: Column(
        children: [
          for (String variation in variations)
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.05),
              child: Row(
                children: [
                  Checkbox(
                    value: checkboxState[variation] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        checkboxState[variation] = value!;
                      });
                    },
                  ),
                  Text(variation),
                  SizedBox(width: screenWidth * 0.02),
                  Container(
                    height: screenWidth * 0.03,
                    width: screenWidth * 0.2,
                    child: TextField(
                      controller: textEditingControllerMap[variation],
                      enabled: checkboxState[variation] ?? false,
                      decoration: InputDecoration(
                        hintText: 'Enter quantity for $variation',
                      ),
                      onEditingComplete: () {
                        // No need to manually update checkboxState here
                        // The onChanged callback handles that
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: customColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            for (String variation in widget.variations) {
              if (checkboxState[variation] == true) {
                String textFieldValue = textEditingControllerMap[variation]?.text ?? '';

                // Check if variation already exists in the list
                int existingIndex = finalvariation.indexOf(variation);

                if (existingIndex != -1) {
                  // If variation exists, replace its corresponding value
                  finalvalues[existingIndex] = textFieldValue;
                } else {
                  // If variation doesn't exist, add it to the lists
                  finalvariation.add(variation);
                  finalvalues.add(textFieldValue);
                }
              }
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const addorder2(),
                settings: RouteSettings(
                  arguments: {
                    'pname': widget.pname,
                    'cname': widget.cname,
                    'cemail': widget.cemail,
                    'phone': widget.phone,
                    'post': widget.post,
                    'address': widget.address,
                    'company' : widget.company,
                    'selectedservice' : widget.service,
                    'finalvariation' : finalvariation,
                    'finalvalues' : finalvalues
                  },
                ),
                // Add more data variables as needed
              ),
            );
          },
        ),
      ],
    );
  }
}
