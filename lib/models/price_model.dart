class PricesModel {
  late String pricesId;
  late String adminId;
  late String vendorId;
  late String vendorName;
  late String catId;
  late String catName;
  late String subCatId;
  late String subCatName;
  late double price;
  late String currencyName;
  late String custId;
  late String custName;
  late String timestamp;

  PricesModel(
      this.pricesId,
      this.custId,
      this.custName,
      this.price,
      this.currencyName,
      this.adminId,
      this.vendorId,
      this.catId,
      this.subCatId,
      this.vendorName,
      this.catName,
      this.subCatName,
      this.timestamp);

  PricesModel.fromJson(Map<String, dynamic> json) {
    pricesId = json['prices_id'];
    custId = json['cust_id'];
    custName = json['cust_name'];
    adminId = json['admin_id'];
    price = json["amount"];
    vendorId = json['vendor_id'];
    catId = json['category_id'];
    subCatId = json['subCatId'];
    vendorName = json['vendor_name'];
    catName = json['category_name'];
    subCatName = json['subCatName'];
    timestamp = json['timestamp'];
    currencyName = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['prices_id'] = this.pricesId;
    data['cust_id'] = this.custId;
    data['cust_name'] = this.custName;
    data["amount"] = this.price;
    // data['amount'] = this.amount;
    data['admin_id'] = this.adminId;
    data['vendor_id'] = this.vendorId;
    data['category_id'] = this.catId;
    data['subCatId'] = this.subCatId;
    data['vendor_name'] = this.vendorName;
    data['category_name'] = this.catName;
    data['subCatName'] = this.subCatName;
    data['timestamp'] = this.timestamp;
    data['currency'] = this.currencyName;
    return data;
  }
}
