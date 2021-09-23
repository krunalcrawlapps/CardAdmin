class VendorModel {
  late String vendorId;
  late String vendorName;
  late String superAdminId;
  late String imageUrl;

  VendorModel(this.vendorId, this.vendorName, this.superAdminId, this.imageUrl);

  VendorModel.fromJson(Map<String, dynamic> json) {
    vendorId = json['vendor_id'];
    vendorName = json['vendor_name'];
    superAdminId = json['superAdminId'];
    imageUrl = json['imageUrl'] == null ? '' : json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vendor_id'] = this.vendorId;
    data['vendor_name'] = this.vendorName;
    data['superAdminId'] = this.superAdminId;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
