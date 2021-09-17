class AdminModel {
  late String adminId;
  late String name;
  late String address;
  late String email;
  late String password;
  late bool isSuperAdmin;
  late bool isBlock;
  String? superAdminId;

  AdminModel(this.adminId, this.name, this.address, this.email, this.password,
      this.isSuperAdmin, this.isBlock, this.superAdminId);

  AdminModel.fromJson(Map<String, dynamic> json) {
    adminId = json['admin_id'];
    name = json['name'];
    address = json['address'];
    email = json['email'];
    password = json['password'];
    isSuperAdmin = json['isSuperAdmin'];
    isBlock = json['isBlock'] == null ? false : json['isBlock'];
    superAdminId = json['superAdminId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['admin_id'] = this.adminId;
    data['name'] = this.name;
    data['address'] = this.address;
    data['email'] = this.email;
    data['password'] = this.password;
    data['isSuperAdmin'] = this.isSuperAdmin;
    data['isBlock'] = this.isBlock;
    data['superAdminId'] = this.superAdminId;
    return data;
  }
}
