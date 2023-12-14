import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:eaziprep_app_desktop/inventory/inventoryProduct.dart';
import 'package:image/image.dart' as img;
import '../homescreen/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/logIn.dart';
import 'inventory.dart';

class inventoryProduct2 extends StatefulWidget {
  static const userinventoryproduct2 = '/inventoryproduct2';

  const inventoryProduct2({super.key});

  @override
  State<inventoryProduct2> createState() => _inventoryProduct2State();
}

class _inventoryProduct2State extends State<inventoryProduct2> {
  bool _loading = false;
  List<File> _imageList = [];
  late String pname = '';
  late String variations = '';
  late String stock = '';
  late String collection = '';
  late String totalproducts='';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Get the current user
    User? user = _auth.currentUser;

    if (user != null) {
      // Get the user's email
      String userEmail = user.email!;

      // Reference to the user's document in the "users" collection
      DocumentReference userRef = _firestore.collection('users').doc(userEmail);

      // Fetch data from Firestore
      try {
        DocumentSnapshot userSnapshot = await userRef.get();

        // Check if the document exists
        if (userSnapshot.exists) {
          // Get the company name and selected services
          setState(() {
            totalproducts = userSnapshot['Total Products'];
          });
        } else {
          print("User document does not exist");
        }

      } catch (e) {
        print("Error fetching data: $e");
      }
    }
  }

  Future<void> _pickImages() async {
    List<XFile>? pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages != null && pickedImages.isNotEmpty) {
      setState(() {
        _loading = true;
      });

      List<File> compressedImages = [];

      for (XFile image in pickedImages) {
        File compressedImage = await _compressImage(File(image.path));
        compressedImages.add(compressedImage);
      }

      setState(() {
        _imageList = compressedImages;
        _loading = false;
      });
    }
  }

  Future<File> _compressImage(File originalImage) async {
    // Read the image file
    List<int> imageBytes = await originalImage.readAsBytes();
    img.Image? original = img.decodeImage(Uint8List.fromList(imageBytes));

    if (original == null) {
      // Handle image decoding error
      return originalImage;
    }

    // Resize the image to your desired dimensions (e.g., 800x800)
    img.Image compressedImage = img.copyResize(original, width: 400, height: 400);

    // Convert the compressed image to bytes
    List<int> compressedBytes = img.encodeJpg(compressedImage);

    // Save the compressed image to a new file
    File compressedFile = File(originalImage.path.replaceAll('.jpg', '_compressed.jpg'));
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }

  Future<String> getUserEmail() async {
    return FirebaseAuth.instance.currentUser?.email ?? '';
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the passed data in the initState or didChangeDependencies
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      pname = arguments['pname'] as String;
      variations = arguments['variations'] as String;
      stock = arguments['stock'] as String;
      collection = arguments['service'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Color customColor = HexColor("#fd7b2e");

    Future<void> _uploadImages() async {
      if (_imageList.isEmpty) {
        AwesomeDialog(context: context,
          width: screenWidth*0.3,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          enableEnterKey: true,
          title: 'Error',
          desc: 'Please select at least 1 picture',
        ).show();
        return;
      }
      setState(() {
        _loading = true;
      });
      int total = int.parse(totalproducts);
      total = total +1;
      totalproducts = total.toString();
      List<String> imageUrls = [];
      String email = await getUserEmail();

      for (File imageFile in _imageList) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child("images/${DateTime.now().millisecondsSinceEpoch}.jpg");
        UploadTask uploadTask = storageReference.putFile(imageFile);

        await uploadTask.whenComplete(() => print('Image uploaded'));

        String downloadURL = await storageReference.getDownloadURL();
        imageUrls.add(downloadURL);
      }

      // Save details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(email).collection(collection).doc(pname).set({
        'pname': pname,
        'variations': variations,
        'stock': stock,
        'imageUrls': imageUrls,
      });

      await FirebaseFirestore.instance.collection('users').doc(email).collection('allproducts').doc(pname).set({
        'pname': pname,
        'variations': variations,
        'stock': stock,
        'imageUrls': imageUrls,
      });

      await FirebaseFirestore.instance.collection('users').doc(email).update({
        'Total Products': totalproducts,
      });

      setState(() {
        _loading = false;
      });

      // Navigate to the next screen or perform any other action
      Navigator.pushReplacementNamed(context, inventory.userinventory);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: customColor,
        title: const Text(
          'Inventory Product',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          color: Colors.white,
          iconSize: 30,
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            // do something when the button is pressed
            Navigator.pushReplacementNamed(context, inventoryProduct.addinventory);
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/home.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: screenWidth * 0.03,
              top: screenWidth * 0.03,
              left: screenWidth * 0.2,
              right: screenWidth * 0.2,
            ),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                color: Colors.white54,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.02),
                    child: Text(
                      'Add Package Details',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: screenWidth * 0.01, right: screenWidth * 0.35),
                    child: Text(
                      'Add images of the product',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenWidth * 0.02,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: screenWidth * 0.01),
                    child: ElevatedButton(
                      onPressed: _pickImages,
                      child: const Text('Pick images of your product'),
                    ),
                  ),
                  Container(
                    height: screenWidth * 0.2,
                    width: screenWidth * 4,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3.0,
                      ),
                    ),
                    child: _imageList.isEmpty
                        ? const Center(
                            child: Text(
                              'No images are selected',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: _imageList.length,
                            itemBuilder: (context, index) {
                              return Image.file(_imageList[index]);
                            },
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.02),
                    child: SizedBox(
                      width: screenWidth * 0.2,
                      child: ElevatedButton(
                        onPressed: _uploadImages,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Add to inventory',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Visibility(
            visible: _loading,
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(customColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
