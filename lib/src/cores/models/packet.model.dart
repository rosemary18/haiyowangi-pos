import 'package:haiyowangi_pos/src/index.dart';

class PacketModel {

  final int id;
  final String? name;
  final String? description;
  double qty;
  final int price;
  final bool? isPublished;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;
  final List<PacketItemModel> items;
  final List<DiscountModel> discounts;

  PacketModel({
    required this.id,
    this.name = "",
    this.description = "",
    this.qty = 0,
    this.price = 0,
    this.isPublished = false,
    this.storeId,
    this.createdAt = "",
    this.updatedAt = "",
    this.items = const [],
    this.discounts = const [],
  });

  factory PacketModel.fromJson(Map<dynamic, dynamic> json) {
    return PacketModel(
      id: json["id"],
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      qty: json["qty"] ?? 0,
      price: json["price"] ?? 0,
      isPublished: json["is_published"] ?? false,
      storeId: json["store_id"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      items: json["items"] == null ? [] : (json["items"] as List).map((e) => PacketItemModel.fromJson(e)).toList(),
      discounts: json["discounts"] == null ? [] : (json["discounts"] as List).map((e) => DiscountModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "qty": qty,
      "price": price,
      "is_published": isPublished,
      "store_id": storeId,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "items": items.map((x) => x.toJson()).toList(),
      "discounts": discounts
    };
  }

}