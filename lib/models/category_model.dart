class CategoryModel {
  late String catId;
  late String vendorId;
  late String catName;
  late String imageUrl;
  late double amount;
  late String currency;

  CategoryModel(this.catId, this.vendorId, this.catName, this.imageUrl,
      this.amount, this.currency);

  CategoryModel.fromJson(Map<String, dynamic> json) {
    catId = json['category_id'];
    vendorId = json['vendor_id'];
    catName = json['category_name'];
    imageUrl = json['imageUrl'];
    amount = json['amount'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.catId;
    data['vendor_id'] = this.vendorId;
    data['category_name'] = this.catName;
    data['imageUrl'] = this.imageUrl;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    return data;
  }
}
