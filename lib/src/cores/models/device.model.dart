class DeviceModel {

  final int id;
  final String? device_id;
  final int? store_id;
  final String? lastSync;
  final String? createdAt;
  final String? updatedAt;

  DeviceModel({
    required this.id,
    this.device_id = "",
    this.store_id,
    this.lastSync = "",
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory DeviceModel.fromJson(Map<dynamic, dynamic> json) {
    return DeviceModel(
      id: json["id"],
      device_id: json["device_id"] ?? "",
      store_id: json["store_id"],
      lastSync: json["last_sync"] ?? "",
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "device_id": device_id,
      "store_id": store_id,
      "last_sync": lastSync,
      "created_at": createdAt,
      "updated_at": updatedAt
    };
  }

}