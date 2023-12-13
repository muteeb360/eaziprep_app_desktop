import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> doesFieldExist(String userEmail, String documentId, String fieldName, String collection) async {
  // Replace 'your_collection_name' with the actual name of the collection
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference specificDocument = firestore
      .collection('users')
      .doc(userEmail)
      .collection(collection)
      .doc(documentId);

  try {
    DocumentSnapshot documentSnapshot = await specificDocument.get();
    Map<String, dynamic>? data =
    documentSnapshot.data() as Map<String, dynamic>?;

    return data != null && data.containsKey(fieldName);
  } catch (e) {
    print('Error checking field existence: $e');
    return false;
  }
}

Future<List<String>> getVariations(String userEmail, String documentId, String fieldName, String collection) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference specificDocument = firestore
      .collection('users')
      .doc(userEmail)
      .collection(collection)
      .doc(documentId);

  try {
    DocumentSnapshot documentSnapshot = await specificDocument.get();
    Map<String, dynamic>? data =
    documentSnapshot.data() as Map<String, dynamic>?;

    // Check if the field exists and has a value
    if (data != null && data.containsKey(fieldName)) {
      String fieldValue = data[fieldName] as String;
      // Split the comma-separated string into a list
      List<String> variations = fieldValue.split(',');
      return variations;
    }

    return [];
  } catch (e) {
    print('Error fetching variations: $e');
    return [];
  }
}

Future<List<String>> fetchIdsArray() async {
  try {
    // Replace 'ordersids' with your actual collection name
    // Replace 'numbers' with your actual document name
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('ordersids').doc('numbers').get();

    // Check if the document exists
    if (snapshot.exists) {
      // Get the 'ids' array from the document data
      List<String>? idsArray = List<String>.from(snapshot.data()?['ids'] ?? []);

      // Return the 'ids' array
      return idsArray;
    } else {
      // Document does not exist
      print('Document does not exist');
      return [];
    }
  } catch (e) {
    // Handle errors
    print('Error fetching ids array: $e');
    return [];
  }
}