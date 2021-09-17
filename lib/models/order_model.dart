class OrderModel {
  late String orderId;
  late int transactionDateTime;
  late String adminId;
  late String custId;
  late String custName;
  List<dynamic> arrCards = [];

  OrderModel(this.orderId, this.transactionDateTime, this.adminId, this.custId,
      this.custName);

  OrderModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    transactionDateTime = json['transaction_date'];
    adminId = json['admin_id'];
    custId = json['cust_id'];
    custName = json['cust_name'];
    arrCards = json['card_ids'] == null ? [] : json['card_ids'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['transaction_date'] = this.transactionDateTime;
    data['admin_id'] = this.adminId;
    data['cust_id'] = this.custId;
    data['cust_name'] = this.custName;
    data['card_ids'] = this.arrCards;
    return data;
  }
}
