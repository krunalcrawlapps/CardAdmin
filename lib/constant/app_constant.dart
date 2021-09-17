class CardStatus {
  static const available = 'Available';
  static const used = 'Used';
}

class StringConstant {
  //common
  static const app_name = 'Card App';
  static const no_data_found = 'No Data Found!';
  static const confirm_delete = "Are you sure you want to delete?";

  //login
  static const login = 'Login';
  static const email_address = 'Email';
  static const enter_email_validation = 'Please enter email';
  static const enter_valid_email_validation =
      'Please enter a valid email address';
  static const password = 'Password';
  static const enter_pwd_validation = 'Please enter password';
  static const enter_valid_pwd_validation =
      'Password should be at least 6 char long';

  //add admin
  static const admins = 'Admins';
  static const add_admin = 'Add Admin';
  static const my_profile = 'My Profile';

  static const enter_name_validation = 'Please enter name';
  static const enter_address_validation = 'Please enter address';
  static const enter_confirm_pwd_validation = 'Please enter confirm password';
  static const invalid_confirm_pwd_validation =
      'Confirm password should be same as password';

  //customer
  static const customers = 'Customers';
  static const enter_balance_validation = 'Please enter balance';

  //cards
  static const cards = 'Cards';
  static const enter_number_validation = 'Please enter card number';
  static const enter_valid_number_validation = 'Card number should be 10 digit';
  static const enter_vendor_validation = 'Please select card vendor';
  static const enter_amount_validation = 'Please enter card amount';
}

class ErrorMessage {
  static const something_wrong = 'Something went wrong, Please try again!';
}

class ImageConstant {
  static const logo_img = 'assets/images/logo.png';
}

class SharedPrefConstant {
  static const user_data = 'userData';
}
