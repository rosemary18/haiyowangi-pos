import 'package:haiyowangi_pos/src/index.dart';

class SaleModel {

  int? id;
  String? code;
  int? status;
  double? total;
  int? discountId;
  int? paymentTypeId;
  int? storeId;
  int? staffId;
  String? createdAt;
  String? updatedAt;
  List<SaleItemModel> items;
  StaffModel? staff;
  DiscountModel? discount;
  PaymentTypeModel? paymentType;
  InvoiceModel? invoice;

  SaleModel({
    this.id,
    this.code = "",
    this.status = 0,
    this.total = 0,
    this.discountId,
    this.paymentTypeId,
    this.storeId,
    this.staffId,
    this.createdAt = "",
    this.updatedAt = "",
    this.staff,
    this.discount,
    this.paymentType,
    this.items = const [],
    this.invoice
  });

  factory SaleModel.fromJson(Map<dynamic, dynamic> json) {
    return SaleModel(
      id: json["id"],
      code: json["code"] ?? "",
      status: json["status"] ?? 0,
      total: double.parse(json["total"].toString()),
      discountId: json["discount_id"],
      paymentTypeId: json["payment_type_id"],
      storeId: json["store_id"],
      staffId: json["staff_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      staff: json["staff"] != null ? StaffModel.fromJson(json["staff"]) : null,
      discount: json["discount"] != null ? DiscountModel.fromJson(json["discount"]) : null,
      paymentType: json["payment_type"] != null ? PaymentTypeModel.fromJson(json["payment_type"]) : null,
      items: json["items"] != null ? List<SaleItemModel>.from(json["items"].map((x) => SaleItemModel.fromJson(x))) : [],
      invoice: json["invoice"] != null ? InvoiceModel.fromJson(json["invoice"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "status": status,
      "total": total,
      "discount_id": discountId,
      "payment_type_id": paymentTypeId,
      "store_id": storeId,
      "staff_id": staffId,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "staff": staff?.toJson(),
      "discount": discount?.toJson(),
      "payment_type": paymentType?.toJson(),
      "items": List<dynamic>.from(items.map((x) => x.toJson())),
      "invoice": invoice?.toJson(),
    };
  }

}