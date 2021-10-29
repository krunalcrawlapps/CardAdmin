import 'dart:convert';

import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/models/admin_model.dart';
import 'package:card_app_admin/models/card_model.dart';
import 'package:card_app_admin/models/category_model.dart';
import 'package:card_app_admin/models/customer_model.dart';
import 'package:card_app_admin/models/price_model.dart';
import 'package:card_app_admin/models/subcategory_model.dart';
import 'package:card_app_admin/models/vendor_model.dart';
import 'package:card_app_admin/utils/date_utils.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseCollectionConstant {
  static const admins = 'Admins';
  static const customer = 'Customers';
  static const cards = 'Cards';
  static const orders = 'Orders';
  static const prices = 'Prices';
  static const vendors = 'Vendors';
  static const transactions = 'Transactions';
  static const category = 'Category';
  static const subcategory = 'SubCategory';
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

  /// Current language
  saveLanguage(String language) async {
    pref.setString(SharedPrefConstant.language, language);
  }

  String? get getLangauge {
    return pref.getString(SharedPrefConstant.language);
  }

  //region Login, Register, ChangePwd
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

  Future<bool> _changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
          email: user?.email ?? '', password: currentPassword);
      UserCredential? userCred = await user?.reauthenticateWithCredential(cred);
      userCred?.user?.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }
  //endregion

  //region Logged User

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
  //endregion

  //region Admin
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
        'isBlock': admin.isBlock,
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  blockAdmin(AdminModel admin) async {
    try {
      // bool isSuccess = await _deleteUserFromAuth(admin.email, admin.password);
      //  if (isSuccess) {
      await _fireStore
          .collection(FirebaseCollectionConstant.admins)
          .doc(admin.adminId)
          .update({'isBlock': true});
      // }
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  unblockAdmin(AdminModel admin) async {
    try {
      // bool isSuccess = await _deleteUserFromAuth(admin.email, admin.password);
      //  if (isSuccess) {
      await _fireStore
          .collection(FirebaseCollectionConstant.admins)
          .doc(admin.adminId)
          .update({'isBlock': false});
      // }
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  updateAdmin(AdminModel admin, String oldPwd, bool isFromMyProfile) async {
    if (admin.password != oldPwd) {
      //update password
      bool isSuccess = await _changePassword(oldPwd, admin.password);
      if (isSuccess) {
        try {
          await _fireStore
              .collection(FirebaseCollectionConstant.admins)
              .doc(admin.adminId)
              .update({
            'name': admin.name,
            'address': admin.address,
            'password': admin.password
          });
        } on FirebaseAuthException catch (error) {
          throw error.message ?? ErrorMessage.something_wrong;
        }
      }
    } else {
      //password not change update other details
      try {
        await _fireStore
            .collection(FirebaseCollectionConstant.admins)
            .doc(admin.adminId)
            .update({
          'name': admin.name,
          'address': admin.address,
        });
      } on FirebaseAuthException catch (error) {
        throw error.message ?? ErrorMessage.something_wrong;
      }
    }

    if (isFromMyProfile) {
      saveUserModel(admin);
    }
  }
  //endregion

  //region Customer Methods
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
        "mobile_number": cust.mobileNumber,
        'cust_address': cust.custAddress,
        'cust_password': cust.custPassword,
        'cust_email': cust.custEmail,
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  blockCustomer(CustomerModel customer) async {
    try {
      // bool isSuccess = await _deleteUserFromAuth(admin.email, admin.password);
      //  if (isSuccess) {
      await _fireStore
          .collection(FirebaseCollectionConstant.customer)
          .doc(customer.custId)
          .update({'isBlock': true});
      // }
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  unblockCustomer(CustomerModel customer) async {
    try {
      // bool isSuccess = await _deleteUserFromAuth(admin.email, admin.password);
      //  if (isSuccess) {
      await _fireStore
          .collection(FirebaseCollectionConstant.customer)
          .doc(customer.custId)
          .update({'isBlock': false});
      // }
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  updateCustomer(String oldPwd, CustomerModel customer) async {
    if (customer.custPassword != oldPwd) {
      //update password
      bool isSuccess = await _changePassword(oldPwd, customer.custPassword);
      if (isSuccess) {
        try {
          await _fireStore
              .collection(FirebaseCollectionConstant.customer)
              .doc(customer.custId)
              .update({
            'cust_name': customer.custName,
            'cust_balance': customer.custBalance,
            "mobile_number": customer.mobileNumber,
            'cust_address': customer.custAddress,
            'cust_password': customer.custPassword,
          });
        } on FirebaseAuthException catch (error) {
          throw error.message ?? ErrorMessage.something_wrong;
        }
      }
    } else {
      //password not change update other details
      try {
        await _fireStore
            .collection(FirebaseCollectionConstant.customer)
            .doc(customer.custId)
            .update({
          'cust_name': customer.custName,
          'cust_balance': customer.custBalance,
          "mobile_number": customer.mobileNumber,
          'cust_address': customer.custAddress,
        });
      } on FirebaseAuthException catch (error) {
        throw error.message ?? ErrorMessage.something_wrong;
      }
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

  updateCustomerBalance(double amount, CustomerModel customer) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.customer)
          .doc(customer.custId)
          .update({'cust_balance': customer.custBalance});

      await addEntryInTransaction(amount, customer);
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  addEntryInTransaction(double amount, CustomerModel customer) async {
    String randomId = getRandomId();

    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.transactions)
          .doc(randomId)
          .set({
        'transaction_id': randomId,
        'datetime':
            DateTimeUtils.getDateTime(DateTime.now().millisecondsSinceEpoch),
        'admin_id': getLoggedInUserModel()?.adminId ?? '',
        'cust_id': customer.custId,
        'amount': amount,
        'newBalance': customer.custBalance,
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }
  //endregion

  //region Card
  addCardData(CardModel card) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.cards)
          .doc(card.cardId)
          .set({
        'card_id': card.cardId,
        'card_number': card.cardNumber,
        'serial_number': card.serialNumber,
        // 'amount': card.amount,
        'card_status': card.cardStatus,
        'admin_id': card.adminId,
        'vendor_id': card.vendorId,
        'category_id': card.catId,
        'subCatId': card.subCatId,
        'vendor_name': card.vendorName,
        'category_name': card.catName,
        'subCatName': card.subCatName,
        'timestamp': card.timestamp,
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  //region Card
  addPricesData(PricesModel card) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.prices)
          .doc(card.pricesId)
          .set(card.toJson());
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  updatePricesData(PricesModel card) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.prices)
          .doc(card.pricesId)
          .update(card.toJson());
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  deletePrices(PricesModel model) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.prices)
          .doc(model.pricesId)
          .delete();
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

  updateCardDetails(CardModel card) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.cards)
          .doc(card.cardId)
          .update({
        //'amount': card.amount,
        'card_number': card.cardNumber,
        'serial_number': card.serialNumber,
        'vendor_id': card.vendorId,
        'category_id': card.catId,
        'subCatId': card.subCatId,
        'vendor_name': card.vendorName,
        'category_name': card.catName,
        'subCatName': card.subCatName,
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  //endregion

  //region Vendor
  addNewVendor(VendorModel vendor) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.vendors)
          .doc(vendor.vendorId)
          .set({
        'vendor_id': vendor.vendorId,
        'vendor_name': vendor.vendorName,
        'superAdminId': vendor.superAdminId,
        'isDirectCharge': vendor.isDirectCharge,
        'imageUrl': vendor.imageUrl
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  // updateVendor(VendorModel vendor) async {
  //   try {
  //     await _fireStore
  //         .collection(FirebaseCollectionConstant.vendors)
  //         .doc(vendor.vendorId)
  //         .set({'vendor_name': vendor.vendorName, 'imageUrl': vendor.imageUrl});
  //   } on FirebaseAuthException catch (error) {
  //     throw error.message ?? ErrorMessage.something_wrong;
  //   }
  // }

  deleteVendor(VendorModel model) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.vendors)
          .doc(model.vendorId)
          .delete();
      await FirebaseStorage.instance.refFromURL(model.imageUrl).delete();
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  Future<List<VendorModel>> getAllVendors() async {
    var collection = _fireStore.collection(FirebaseCollectionConstant.vendors);
    var querySnapshot = await collection.get();

    List<VendorModel> arrVendors = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      VendorModel model = VendorModel.fromJson(data);
      arrVendors.add(model);
    }

    return arrVendors;
  }

  Future<List<CategoryModel>> getAllCategory() async {
    var collection = _fireStore.collection(FirebaseCollectionConstant.category);
    var querySnapshot = await collection.get();

    List<CategoryModel> arrCategory = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      CategoryModel model = CategoryModel.fromJson(data);
      arrCategory.add(model);
    }

    return arrCategory;
  }

  Future<List<SubCategoryModel>> getAllSubCategory() async {
    var collection =
        _fireStore.collection(FirebaseCollectionConstant.subcategory);
    var querySnapshot = await collection.get();

    List<SubCategoryModel> arrSubCategory = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      SubCategoryModel model = SubCategoryModel.fromJson(data);
      arrSubCategory.add(model);
    }

    return arrSubCategory;
  }

  Future<List<CustomerModel>> getAllCustmoers() async {
    var collection = _fireStore
        .collection(FirebaseCollectionConstant.customer)
        .where('admin_id',
            isEqualTo: DatabaseHelper.shared.getLoggedInUserModel()?.adminId);
    var querySnapshot = await collection.get();

    List<CustomerModel> arrSubCategory = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();

      CustomerModel model = CustomerModel.fromJson(data);
      arrSubCategory.add(model);
    }

    return arrSubCategory;
  }

  //endregion

  //region Category/SubCategory
  addUpdateCategory(CategoryModel category) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.category)
          .doc(category.catId)
          .set({
        'category_id': category.catId,
        'category_name': category.catName,
        'vendor_id': category.vendorId,
        'imageUrl': category.imageUrl,
        'amount': category.amount,
        'currency': category.currency
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  deleteCategory(CategoryModel model) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.category)
          .doc(model.catId)
          .delete();
      await FirebaseStorage.instance.refFromURL(model.imageUrl).delete();
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  addUpdateSubCategory(SubCategoryModel subCategoryModel) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.subcategory)
          .doc(subCategoryModel.subCatId)
          .set({
        'subCatId': subCategoryModel.subCatId,
        'category_id': subCategoryModel.catId,
        'subCatName': subCategoryModel.subCatName,
        'imageUrl': subCategoryModel.imageUrl,
        'amount': subCategoryModel.amount,
        'currency': subCategoryModel.currency
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  deleteSubCategory(SubCategoryModel model) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.subcategory)
          .doc(model.subCatId)
          .delete();
      FirebaseStorage.instance.refFromURL(model.imageUrl).delete();
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    } catch (e) {
      rethrow;
    }
  }

  updateDirectChargeStatus(String orderId) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.orders)
          .doc(orderId)
          .update({
        'fulfilmentStatus': 'Complete',
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }
//endregion
}
