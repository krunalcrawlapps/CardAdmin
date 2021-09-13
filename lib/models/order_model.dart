class OrderModel {
  late String orderId;
  late String cardId;
  late int transactionDateTime;
  late String adminId;
  late String custId;
  late String cardVendor;
  late int cardNumber;
  late String custName;

  OrderModel(this.orderId, this.cardId, this.transactionDateTime, this.adminId,
      this.custId, this.cardNumber, this.cardVendor, this.custName);

  OrderModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    cardId = json['card_id'];
    transactionDateTime = json['transaction_date'];
    adminId = json['admin_id'];
    custId = json['cust_id'];
    cardVendor = json['card_vendor'];
    cardNumber = json['card_number'];
    custName = json['cust_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['card_id'] = this.cardId;
    data['transaction_date'] = this.transactionDateTime;
    data['admin_id'] = this.adminId;
    data['cust_id'] = this.custId;
    data['card_vendor'] = this.cardVendor;
    data['card_number'] = this.cardNumber;
    data['cust_name'] = this.custName;
    return data;
  }
}
