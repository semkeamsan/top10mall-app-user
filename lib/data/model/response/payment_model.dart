class PaymentModel {
  String paymentURL;
  String bankName;

  PaymentModel({this.paymentURL, this.bankName});

  PaymentModel.fromJson(Map<String, dynamic> json) {
    paymentURL = json['payment_image'];
    bankName = json['bank_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_image'] = this.paymentURL;
    data['bank_name'] = this.bankName;
    return data;
  }
}
