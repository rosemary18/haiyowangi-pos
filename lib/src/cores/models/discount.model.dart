import 'package:haiyowangi_pos/src/index.dart';

class DiscountModel {

  int? id;
  String? name;
  String? code;
  double? nominal;
  double? percentage;
  bool isPercentage;
  String? dateValid;
  String? validUntil;
  int? multiplication;
  double? maxItemsQty;
  double? minItemsQty;
  int? specialForProductId;
  int? specialForVariantId;
  int? specialForPacketId;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  ProductModel? product;
  VariantModel? variant;
  PacketModel? packet;

  DiscountModel({
    this.id,
    this.name = "",
    this.code = "",
    this.nominal = 0,
    this.percentage = 0,
    this.isPercentage = false,
    this.dateValid = "",
    this.validUntil = "",
    this.multiplication = 0,
    this.maxItemsQty = 0,
    this.minItemsQty = 0,
    this.specialForProductId,
    this.specialForVariantId,
    this.specialForPacketId,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
    this.product,
    this.variant,
    this.packet
  });

  factory DiscountModel.fromJson(Map<dynamic, dynamic> json) {
    return DiscountModel(
      id: json["id"],
      name: json["name"] ?? "",
      code: json["code"] ?? "",
      nominal: double.parse(json["nominal"].toString()),
      percentage: double.parse(json["percentage"].toString()),
      isPercentage: json["is_percentage"] ?? false,
      dateValid: json["date_valid"] ?? "",
      validUntil: json["valid_until"] ?? "",
      multiplication: json["multiplication"] ?? 0,
      maxItemsQty: double.parse(json["max_items_qty"].toString()),
      minItemsQty: double.parse(json["min_items_qty"].toString()),
      specialForProductId: json["special_for_product_id"],
      specialForVariantId: json["special_for_variant_id"],
      specialForPacketId: json["special_for_packet_id"],
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      product: json["product"] != null ? ProductModel.fromJson(json["product"]) : null,
      variant: json["variant"] != null ? VariantModel.fromJson(json["variant"]) : null,
      packet: json["packet"] != null ? PacketModel.fromJson(json["packet"]) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "code": code,
      "nominal": nominal,
      "percentage": percentage,
      "is_percentage": isPercentage,
      "date_valid": dateValid,
      "valid_until": validUntil,
      "multiplication": multiplication,
      "max_items_qty": maxItemsQty,
      "min_items_qty": minItemsQty,
      "special_for_product_id": specialForProductId,
      "special_for_variant_id": specialForVariantId,
      "special_for_packet_id": specialForPacketId,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "product": product?.toJson(),
      "variant": variant?.toJson(),
      "packet": packet?.toJson()
    }; 
  }

}