class CardModel {
  late String cardId;
  late int cardNumber;
  late double amount;
  late String cardStatus;
  late String adminId;
  late String cardVendor;
  late String vendorId;

  CardModel(this.cardId, this.cardNumber, this.amount, this.cardStatus,
      this.adminId, this.cardVendor, this.vendorId);

  CardModel.fromJson(Map<String, dynamic> json) {
    cardId = json['card_id'];
    cardNumber = json['card_number'];
    amount = json['amount'];
    cardStatus = json['card_status'];
    adminId = json['admin_id'];
    cardVendor = json['card_vendor'];
    vendorId = json['vendor_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_id'] = this.adminId;
    data['card_number'] = this.cardNumber;
    data['amount'] = this.amount;
    data['card_status'] = this.cardStatus;
    data['admin_id'] = this.adminId;
    data['vendor_id'] = this.vendorId;
    return data;
  }
}
