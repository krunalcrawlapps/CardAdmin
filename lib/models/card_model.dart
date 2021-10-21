class CardModel {
  late String cardId;
  late dynamic cardNumber;
  // late double amount;
  late String cardStatus;
  late String adminId;
  late String vendorId;
  late String vendorName;
  late String catId;
  late String catName;
  late String subCatId;
  late String subCatName;
  late int timestamp;

  CardModel(
      this.cardId,
      this.cardNumber,
      this.cardStatus,
      this.adminId,
      this.vendorId,
      this.catId,
      this.subCatId,
      this.vendorName,
      this.catName,
      this.subCatName,
      this.timestamp);

  CardModel.fromJson(Map<String, dynamic> json) {
    cardId = json['card_id'];
    cardNumber = json['card_number'];
    // amount = json['amount'];
    cardStatus = json['card_status'];
    adminId = json['admin_id'];
    vendorId = json['vendor_id'];
    catId = json['category_id'];
    subCatId = json['subCatId'];
    vendorName = json['vendor_name'];
    catName = json['category_name'];
    subCatName = json['subCatName'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_id'] = this.adminId;
    data['card_number'] = this.cardNumber;
    // data['amount'] = this.amount;
    data['card_status'] = this.cardStatus;
    data['admin_id'] = this.adminId;
    data['vendor_id'] = this.vendorId;
    data['category_id'] = this.catId;
    data['subCatId'] = this.subCatId;
    data['vendor_name'] = this.vendorName;
    data['category_name'] = this.catName;
    data['subCatName'] = this.subCatName;
    data['timestamp'] = this.timestamp;
    return data;
  }
}
