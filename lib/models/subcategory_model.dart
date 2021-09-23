class SubCategoryModel {
  late String subCatId;
  late String catId;
  late String subCatName;
  late String imageUrl;
  late double amount;
  late String currency;

  SubCategoryModel(this.subCatId, this.catId, this.subCatName, this.imageUrl,
      this.amount, this.currency);

  SubCategoryModel.fromJson(Map<String, dynamic> json) {
    subCatId = json['subCatId'];
    catId = json['category_id'];
    subCatName = json['subCatName'];
    imageUrl = json['imageUrl'];
    amount = json['amount'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subCatId'] = this.subCatId;
    data['category_id'] = this.catId;
    data['subCatName'] = this.subCatName;
    data['imageUrl'] = this.imageUrl;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    return data;
  }
}
