class CustomerModel {
  late String custId;
  late String custName;
  late double custBalance;
  late String adminId;
  late String custAddress;
  late String custPassword;
  late String custEmail;

  CustomerModel(this.custId, this.custName, this.custBalance, this.adminId,
      this.custAddress, this.custPassword, this.custEmail);

  CustomerModel.fromJson(Map<String, dynamic> json) {
    custId = json['cust_id'];
    custName = json['cust_name'];
    custBalance = json['cust_balance'];
    adminId = json['admin_id'];
    custAddress = json['cust_address'];
    custPassword = json['cust_password'];
    custEmail = json['cust_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cust_id'] = this.adminId;
    data['cust_name'] = this.custName;
    data['cust_balance'] = this.custBalance;
    data['admin_id'] = this.adminId;
    data['cust_address'] = this.custAddress;
    data['cust_password'] = this.custPassword;
    data['cust_email'] = this.custEmail;
    return data;
  }
}
