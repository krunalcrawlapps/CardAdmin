class VendorModel {
  late String vendorId;
  late String vendorName;
  late String superAdminId;

  VendorModel(this.vendorId, this.vendorName, this.superAdminId);

  VendorModel.fromJson(Map<String, dynamic> json) {
    vendorId = json['vendor_id'];
    vendorName = json['vendor_name'];
    superAdminId = json['superAdminId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vendor_id'] = this.vendorId;
    data['vendor_name'] = this.vendorName;
    data['superAdminId'] = this.superAdminId;
    return data;
  }
}
