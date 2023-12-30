import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../welcomeScreen.dart';
import 'logIn.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class signup extends StatefulWidget {
  static const register = "/signup";

  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  bool _loading = false;
  final TextEditingController name = TextEditingController();
  final TextEditingController companyname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final phone = MaskedTextController(mask: "00000-000000");
  final TextEditingController address = TextEditingController();


  File? _imageFile;
  final picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _imageUrl = '';

  Future<void> makeaccount()async{
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.text.trim(),
      password: password.text,
    );
  }



  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await picker.getImage(source: source);

    setState(() async {
      if (pickedImage != null) {
        // Read the image file
        List<int> imageBytes = await File(pickedImage.path).readAsBytes();
        img.Image? originalImage = img.decodeImage(Uint8List.fromList(imageBytes));

        if (originalImage != null) {
          // Resize the image to your desired dimensions (e.g., 800x800)
          img.Image compressedImage = img.copyResize(originalImage, width: 400, height: 400);

          // Convert the compressed image to bytes
          List<int> compressedBytes = img.encodeJpg(compressedImage);

          // Save the compressed image to a new file
          File compressedFile = File(pickedImage.path.replaceAll('.jpg', '_compressed.jpg'));
          await compressedFile.writeAsBytes(compressedBytes);

          setState(() {
            _imageFile = compressedFile;
          });
        } else {
          // Handle image decoding error
          print('Error decoding image.');
        }
      } else {
        print('No image selected.');
      }
    });
  }


  Future<void> _uploadImageToStorage() async {
    try {
        final userEmail = email.text;
        final storageRef = _storage.ref().child('user_images/$userEmail.jpg');
        final uploadTask = storageRef.putFile(_imageFile!);
        final snapshot = await uploadTask.whenComplete(() {});

        if (snapshot.state == TaskState.success) {
          final downloadUrl = await storageRef.getDownloadURL();
          final userDocRef = FirebaseFirestore.instance
              .collection('users')
              .doc(userEmail);

          await userDocRef.set(
            {
              'imageUrl': downloadUrl,
            },
            SetOptions(merge: true),
          );

          setState(() {
            _imageUrl = downloadUrl;
          });
        }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Color customColor = HexColor("#fd7b2e");

    Future<void> signUp() async {
      if (name.text.isEmpty ||
          companyname.text.isEmpty ||
          email.text.isEmpty ||
          password.text.isEmpty ||
          phone.text.isEmpty ||
          address.text.isEmpty) {
        AwesomeDialog(context: context,
          width: screenWidth*0.3,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          enableEnterKey: true,
          title: 'Error',
          desc: 'Please fill all fields',
        ).show();
        return;
      }
      setState(() {
        _loading = true;
      });

      try {
        _uploadImageToStorage().then((_) {});
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );

        // Add user details to Firestore
        await FirebaseFirestore.instance.collection('users').doc(email.text.trim()).set({
          'email': email.text.trim(),
          'Total Products': '0',
          'name': name.text,
          'company_name': companyname.text,
          'phone': phone.text,
          'address': address.text,
          'imageUrl':_imageUrl
          // Add more fields as needed
        });
        setState(() {
          _loading = false;
        });

        // Navigate to the login screen after successful registration
        Navigator.pushReplacementNamed(context, login.signin);
      } on FirebaseAuthException catch (e) {
        print("Error signing up: $e");
        AwesomeDialog(context: context,
          width: screenWidth*0.3,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          enableEnterKey: true,
          title: 'Error',
          desc: 'Error Signing Up. Cause $e',
        ).show();
      }

    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(
            context, welcomescreen.welcome);
        return true;
      },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: _loading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                AssetImage('assets/signup.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only( right: screenWidth*0.95,top: screenWidth*0.01),
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    Padding(
                      padding: EdgeInsets.only(bottom: screenWidth*0),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.getFont(
                          'Outfit',
                          textStyle: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),


                    GestureDetector(
                      onTap: () {
                        _pickImage(ImageSource.gallery);
                      },
                      child: CircleAvatar(
                        radius: screenWidth * 0.05,
                        backgroundColor: Colors.grey, // Set a default background color
                        child: _imageFile != null || _imageUrl.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(screenWidth * 0.1),
                          child: _imageFile != null
                              ? Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                              : Image.network(
                            _imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                            : Center(
                          // Display a message when no image is selected
                          child: Text(
                            'Select an Image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.02, left: screenWidth * 0.35, right: screenWidth * 0.35),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: name,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.01,left: screenWidth * 0.35, right: screenWidth * 0.35),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: companyname,
                          decoration: InputDecoration(
                            hintText: 'Company Name',
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.01,left: screenWidth * 0.35, right: screenWidth * 0.35),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: email,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.01,left: screenWidth * 0.35, right: screenWidth * 0.35),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: password,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.01,left: screenWidth * 0.35, right: screenWidth * 0.35),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          controller: phone,
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.01,left: screenWidth * 0.35, right: screenWidth * 0.35),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: address,
                          decoration: InputDecoration(
                            hintText: 'Address',
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.02, left: screenWidth * 0.4, right: screenWidth * 0.4),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){
                            signUp();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
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
    );
  }
}
