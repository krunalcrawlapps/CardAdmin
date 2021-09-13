class CardModel {
  late String cardId;
  late String cardVendor;
  late int cardNumber;
  late double amount;
  late String cardStatus;
  late String adminId;

  CardModel(this.cardId, this.cardVendor, this.cardNumber, this.amount,
      this.cardStatus, this.adminId);

  CardModel.fromJson(Map<String, dynamic> json) {
    cardId = json['card_id'];
    cardVendor = json['card_vendor'];
    cardNumber = json['card_number'];
    amount = json['amount'];
    cardStatus = json['card_status'];
    adminId = json['admin_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_id'] = this.adminId;
    data['card_vendor'] = this.cardVendor;
    data['card_number'] = this.cardNumber;
    data['amount'] = this.amount;
    data['card_status'] = this.cardStatus;
    data['admin_id'] = this.adminId;
    return data;
  }
}
