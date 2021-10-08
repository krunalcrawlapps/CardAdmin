class OrderModel {
  late String orderId;
  late String transactionDateTime;
  late String adminId;
  late String custId;
  late String custName;
  List<dynamic> arrCards = [];
  late bool isDirectCharge;
  late String accountId;
  late String secAccountId;
  late String fulfilmentStatus;
  late double amount;
  late String vendorName;
  late String catName;

  OrderModel(
      this.orderId,
      this.transactionDateTime,
      this.adminId,
      this.custId,
      this.custName,
      this.isDirectCharge,
      this.accountId,
      this.secAccountId,
      this.fulfilmentStatus,
      this.amount,
      this.vendorName,
      this.catName);

  OrderModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    transactionDateTime = json['transaction_date'];
    adminId = json['admin_id'];
    custId = json['cust_id'];
    custName = json['cust_name'];
    arrCards = json['card_ids'] == null ? [] : json['card_ids'];
    isDirectCharge = json['isDirectCharge'];
    accountId = json['accountId'];
    secAccountId = json['secAccountId'];
    fulfilmentStatus = json['fulfilmentStatus'];
    amount = json['amount'];
    vendorName = json['vendor_name'];
    catName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['transaction_date'] = this.transactionDateTime;
    data['admin_id'] = this.adminId;
    data['cust_id'] = this.custId;
    data['cust_name'] = this.custName;
    data['card_ids'] = this.arrCards;
    data['isDirectCharge'] = this.isDirectCharge;
    data['accountId'] = this.accountId;
    data['secAccountId'] = this.secAccountId;
    data['fulfilmentStatus'] = this.fulfilmentStatus;
    data['amount'] = this.amount;
    data['vendor_name'] = this.vendorName;
    data['category_name'] = this.catName;
    return data;
  }
}
