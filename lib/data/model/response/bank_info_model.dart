class BankInforModel {
  List<DataBank> data;

  BankInforModel({this.data});

  BankInforModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DataBank>[];
      json['data'].forEach((v) {
        data.add(new DataBank.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DataBank {
  String bankName;
  String holderName;
  String accountNo;

  DataBank({this.bankName, this.holderName, this.accountNo});

  DataBank.fromJson(Map<String, dynamic> json) {
    bankName = json['bank_name'];
    holderName = json['holder_name'];
    accountNo = json['account_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bank_name'] = this.bankName;
    data['holder_name'] = this.holderName;
    data['account_no'] = this.accountNo;
    return data;
  }
}
