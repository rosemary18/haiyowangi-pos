import 'package:haiyowangi_pos/src/index.dart';

class InvoiceModel {

  int? id;
  String? code;
  int? salesId;
  int? paymentId;
  int? status;
  int? discount;
  int? subTotal;
  int? total;
  int? cash;
  int? changeMoney;
  String? createdAt;
  String? updatedAt;
  PaymentModel? payment;

  InvoiceModel({
    this.id,
    this.code = "",
    this.salesId,
    this.paymentId,
    this.status = 0,
    this.discount = 0,
    this.subTotal = 0,
    this.total = 0,
    this.cash = 0,
    this.changeMoney = 0,
    this.createdAt = "",
    this.updatedAt = "",
    this.payment
  });

  factory InvoiceModel.fromJson(Map<dynamic, dynamic> json) {
    return InvoiceModel(
      id: json["id"],
      code: json["code"] ?? "",
      salesId: json["sales_id"],
      paymentId: json["payment_id"],
      status: json["status"] ?? 0,
      discount: json["discount"] ?? 0,
      subTotal: json["sub_total"] ?? 0,
      total: json["total"] ?? 0,
      cash: json["cash"] ?? 0,
      changeMoney: json["change_money"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      payment: json["payment"] == null ? null : PaymentModel.fromJson(json["payment"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "sales_id": salesId,
      "payment_id": paymentId,
      "status": status,
      "discount": discount,
      "sub_total": subTotal,
      "total": total,
      "cash": cash,
      "change_money": changeMoney,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "payment": payment?.toJson(),
    };
  }
  
}