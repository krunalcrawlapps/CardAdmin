class VendorModel {
  late String vendorId;
  late String vendorName;
  late String superAdminId;
  late String imageUrl;
  late bool isDirectCharge;

  VendorModel(this.vendorId, this.vendorName, this.superAdminId, this.imageUrl,
      this.isDirectCharge);

  VendorModel.fromJson(Map<String, dynamic> json) {
    vendorId = json['vendor_id'];
    vendorName = json['vendor_name'];
    superAdminId = json['superAdminId'];
    imageUrl = json['imageUrl'] == null ? '' : json['imageUrl'];
    isDirectCharge = json['isDirectCharge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vendor_id'] = this.vendorId;
    data['vendor_name'] = this.vendorName;
    data['superAdminId'] = this.superAdminId;
    data['imageUrl'] = this.imageUrl;
    data['isDirectCharge'] = this.isDirectCharge;
    return data;
  }
}
