import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'addorderhelper.dart';
import '../helpers/DropDownHelper.dart';
import '../homescreen/homescreen.dart';
import 'package:flutter/material.dart';
import '../helpers/textfield.dart';
import '../auth/logIn.dart';
import 'variations.dart';

class addorder extends StatefulWidget {
  static const add = '/addorder';

  const addorder({super.key});

  @override
  State<addorder> createState() => _addorderState();
}

class _addorderState extends State<addorder> {
  final TextEditingController product = TextEditingController();
  final TextEditingController customer = TextEditingController();
  final TextEditingController customeremail = TextEditingController();
  final phone = MaskedTextController(mask: "00000-000000");
  final TextEditingController post = TextEditingController();
  final TextEditingController address = TextEditingController();
  String selectedservice='';
  String selectedproduct='';
  List<String> variations = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String companyName = "";
  List<String> selectedServices = [];
  List<String> productNames=[];
  bool isLoading = false;
  int stocks=0;
  @override
  void initState() {
    super.initState();
    print('initState called!');
    fetchData();
  }

  Future<void> fetchData() async {
    print('inside fetchdata');
    setState(() {
      isLoading = true;
    });

    _auth.authStateChanges().listen((User? user) async{
      if (user != null) {
        print('iniside user');
        // Get the user's email
        String userEmail = user.email!;

        // Reference to the user's document in the "users" collection
        DocumentReference userRef = _firestore.collection('users').doc(
            userEmail);

        // Fetch data from Firestore
        try {
          print('iniside try');
          DocumentSnapshot userSnapshot = await userRef.get();

          // Check if the document exists
          if (userSnapshot.exists) {
            // Get the company name and selected services
            setState(() {
              companyName = userSnapshot['company_name'];
              selectedServices = List<String>.from(userSnapshot['selectedServices']);
            });
          } else {
            print("User document does not exist");
          }
          print("fetched data of company name and services");
        } catch (e) {
          print("Error fetching data: $e");
        }
      } else {
        print('user is null');
      }
    });
    print('going now');
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getSubcollectionDocumentNames() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    String userEmail='';
    if (user != null) {
      userEmail = user.email!;
    }

    try {
      // Reference to the user's document using their email
      DocumentReference userDocument = firestore.collection('users').doc(userEmail);

      // Reference to the specified subcollection
      CollectionReference subcollectionReference = userDocument.collection(selectedservice);

      // Get documents from the subcollection
      QuerySnapshot querySnapshot = await subcollectionReference.get();

      // Extract document names from the query snapshot
      setState(() {
        productNames = querySnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error fetching subcollection documents: $e');
    }
  }

  Future<void> getData() async {
    User? user = _auth.currentUser;
    String userEmail='';
    if (user != null) {
      userEmail = user.email!;
    }
    bool fieldExists = await doesFieldExist(
        userEmail, selectedproduct, 'variations',selectedservice);

    if (fieldExists) {
      // Fetch variations and update the state
      List<String> fetchedVariations = await getVariations(userEmail, selectedproduct, 'variations',selectedservice);
      String stock = await getStock(userEmail, selectedproduct, 'stock',selectedservice);
      setState(() {
        variations = fetchedVariations;
        stocks = int.parse(stock);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Color customColor = HexColor("#fd7b2e");

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: customColor,
          title: const Text('Order',style: TextStyle(color: Colors.white),),
          leading:
            IconButton(
              color: Colors.white,
              iconSize: 30,
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () {
                // do something when the button is pressed
                Navigator.pushReplacementNamed(context, homescreen.home);
              },
            ),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Stack(
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
                bottom: screenWidth*0.03,
                  top: screenWidth * 0.03,
                  left: screenWidth * 0.2,
                  right: screenWidth * 0.2),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  color: Colors.white54,
                ),
                child: SingleChildScrollView(
                  child:  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenWidth * 0.01),
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
                            top: screenWidth * 0.02,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: DropDownHelper(
                          services: selectedServices,
                          onServiceSelected: (selectedValue) {
                            setState(() {
                              selectedservice = selectedValue;
                              selectedproduct='';
                              getSubcollectionDocumentNames();
                              print('Selected service is $selectedValue');
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.01,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: productDropDownHelper(
                          services: productNames,
                          onServiceSelected: (selectedValue) {
                            setState(() {
                              selectedproduct = selectedValue;
                              getData();
                              print('Selected product is $selectedValue');
                            });
                          },
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.01,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: textfield(
                            controller: customer, hintText: 'Customer Name',keyboardtype: 'text'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.01,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: textfield(
                            controller: customeremail, hintText: 'Customer Email',keyboardtype: 'text'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.01,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: textfield1(
                            controller: phone, hintText: 'Phone Number',keyboardtype: 'phone'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.01,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: textfield(controller: post, hintText: 'Post Code',keyboardtype: 'number'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.01,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: textfield(
                            controller: address, hintText: 'Street Address',keyboardtype: 'text'),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.02,
                            left: screenWidth * 0.15,
                            right: screenWidth * 0.15),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedproduct.isEmpty ||
                                  customer.text.isEmpty ||
                                  customeremail.text.isEmpty ||
                                  phone.text.isEmpty ||
                                  post.text.isEmpty ||
                                  address.text.isEmpty ||
                                  selectedservice.isEmpty) {
                                AwesomeDialog(context: context,
                                width: screenWidth*0.3,
                                dialogType: DialogType.error,
                                animType: AnimType.topSlide,
                                enableEnterKey: true,
                                title: 'Error',
                                desc: 'Please fill all fields',
                                btnOkOnPress: (){
                                  Navigator.pushReplacementNamed(context, addorder.add);
                                }).show();
                              } else if(stocks==0){
                                AwesomeDialog(context: context,
                                    width: screenWidth*0.3,
                                    dialogType: DialogType.error,
                                    animType: AnimType.topSlide,
                                    enableEnterKey: true,
                                    title: 'Error',
                                    desc: 'Product stock is 0',
                                    btnOkOnPress: (){
                                      Navigator.pushReplacementNamed(context, addorder.add);
                                    }).show();
                              }else {
                                print('Selected service is $selectedservice');
                                _showDialog(context,customer.text,selectedproduct,customeremail.text,address.text,selectedservice,post.text,phone.text,companyName);
                              }
                            },
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
  void _showDialog(BuildContext context,String cname,String pname, String cemail, String address, String service, String post, String phone,String company) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return YourDialog(variations: variations,pname: pname,cname: cname,service: service,cemail: cemail,address: address,phone: phone,post: post,company: company); // Use your Stateful dialog
      },
    );
  }
}
