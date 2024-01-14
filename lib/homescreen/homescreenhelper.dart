import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> getUserData(String email) async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(email).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      // Extract specific fields
      String name = userData['name'] ?? '';
      String phone = userData['phone'] ?? '';
      String imageUrl = userData['imageUrl'] ?? '';
      String companyName = userData['company_name'] ?? '';
      // Get the 'services' field from the document
      List<dynamic> services = userSnapshot.get('selectedServices') ?? [];

      // Convert the services to a list of strings
      List<String> serviceList =
      services.map((dynamic service) => service.toString()).toList();
      print(name+phone+imageUrl);

      return {
        'name': name,
        'phone': phone,
        'imageUrl': imageUrl,
        'company_name': companyName,
        'services': serviceList
      };
    } else {
      // Document doesn't exist
      return {};
    }
  } catch (error) {
    print('Error fetching user data: $error');
    return {};
  }
}