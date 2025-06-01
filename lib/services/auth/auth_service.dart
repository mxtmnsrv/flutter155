import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get current user
  User? getCurrentUser()  {
    return _auth.currentUser;
  }
  //sign in
  Future<UserCredential> signWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
  Future<Map<String, dynamic>?> getUserDetails(String uid) async {

    if (uid.isEmpty) {
      print("UID cannot be empty for getUserDetails.");
      return null;
    }
    try {
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          bool isCustomer = (data['type'] == 'customer'); // Your logic for isCustomer
          String? name = data['name'] as String?;
          return {'isCustomer': isCustomer, 'name': name ?? 'User'}; // Provide default name if null
        }
      }
      return {'isCustomer': false, 'name': 'User'}; // Default if user or data not found
    } catch (e) {
      print("Error fetching user details for UID $uid: $e");
      return {'isCustomer': false, 'name': 'User'}; // Default in case of error
    }
  }
}
