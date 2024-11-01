class PaymentTypeModel {

  int? id;
  String? name;
  String? description;
  String? code;
  String? createdAt;
  String? updatedAt;

  PaymentTypeModel({
    this.id,
    this.name = "",
    this.description = "",
    this.code = "",
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory PaymentTypeModel.fromJson(Map<dynamic, dynamic> json) {
    return PaymentTypeModel(
      id: json["id"],
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      code: json["code"] ?? "",
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "code": code,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }
  
}