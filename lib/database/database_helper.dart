import 'dart:convert';

import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/models/admin_model.dart';
import 'package:card_app_admin/models/card_model.dart';
import 'package:card_app_admin/models/customer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseCollectionConstant {
  static const admins = 'Admins';
  static const customer = 'Customers';
  static const cards = 'Cards';
  static const orders = 'Orders';
}

class DatabaseHelper {
  static DatabaseHelper _instance = DatabaseHelper._();
  DatabaseHelper._();
  static DatabaseHelper get shared => _instance;

  late FirebaseFirestore _fireStore;
  late FirebaseAuth _auth;
  late SharedPreferences pref;

  initDatabase() async {
    _fireStore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    pref = await SharedPreferences.getInstance();
  }

  ///Login, Register, Delete
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential? userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  Future<User?> doLogin(String email, String password) async {
    try {
      UserCredential? userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  Future<bool> _deleteUserFromAuth(String email, String password) async {
    try {
      await doLogin(email, password);
      User? user = _auth.currentUser;
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);
      UserCredential? result =
          await user?.reauthenticateWithCredential(credential);
      await result?.user?.delete();

      //again login with current user
      await doLogin(getLoggedInUserModel()?.email ?? '',
          getLoggedInUserModel()?.password ?? '');
      return true;
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  ///Login User Data
  Future<AdminModel?> getUserDataFromFirebase(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> result = await _fireStore
        .collection(FirebaseCollectionConstant.admins)
        .doc(userId)
        .get();
    Map<String, dynamic>? data = result.data();
    if (data != null) {
      return AdminModel.fromJson(data);
    } else {
      return null;
    }
  }

  saveUserModel(AdminModel user) async {
    String userStr = jsonEncode(user);
    pref.setString(SharedPrefConstant.user_data, userStr);
  }

  AdminModel? getLoggedInUserModel() {
    String? userStr = pref.getString(SharedPrefConstant.user_data);

    if (userStr != null) {
      Map<String, dynamic> json = jsonDecode(userStr);
      return AdminModel.fromJson(json);
    }

    return null;
  }

  clearUserData() {
    _auth.signOut();
    pref.clear();
  }

  /// Admin
  addAdminData(AdminModel admin) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.admins)
          .doc(admin.adminId)
          .set({
        'admin_id': admin.adminId,
        'name': admin.name,
        'address': admin.address,
        'email': admin.email,
        'password': admin.password,
        'isSuperAdmin': admin.isSuperAdmin,
        'superAdminId': admin.superAdminId,
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  deleteAdmin(AdminModel admin) async {
    try {
      bool isSuccess = await _deleteUserFromAuth(admin.email, admin.password);
      if (isSuccess) {
        await _fireStore
            .collection(FirebaseCollectionConstant.admins)
            .doc(admin.adminId)
            .delete();
      }
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  ///Customer
  addCustomerData(CustomerModel cust) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.customer)
          .doc(cust.custId)
          .set({
        'cust_id': cust.custId,
        'cust_name': cust.custName,
        'cust_balance': cust.custBalance,
        'admin_id': cust.adminId,
        'cust_address': cust.custAddress,
        'cust_password': cust.custPassword,
        'cust_email': cust.custEmail,
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  deleteCustomer(CustomerModel customer) async {
    try {
      bool isSuccess =
          await _deleteUserFromAuth(customer.custEmail, customer.custPassword);
      if (isSuccess) {
        await _fireStore
            .collection(FirebaseCollectionConstant.customer)
            .doc(customer.custId)
            .delete();
      }
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  ///Card
  addCardData(CardModel card) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.cards)
          .doc(card.cardId)
          .set({
        'card_id': card.cardId,
        'card_vendor': card.cardVendor,
        'card_number': card.cardNumber,
        'amount': card.amount,
        'card_status': card.cardStatus,
        'admin_id': card.adminId,
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  deleteCard(String cardId) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.cards)
          .doc(cardId)
          .delete();
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }
}
