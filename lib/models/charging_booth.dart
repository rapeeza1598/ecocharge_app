import 'dart:convert';

List<ChargingBooth> chargingBoothFromJson(String str) => List<ChargingBooth>.from(json.decode(str).map((x) => ChargingBooth.fromJson(x)));

String chargingBoothToJson(List<ChargingBooth> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChargingBooth {
    final String boothId;
    final String boothName;
    final String stationId;
    final String status;
    final double chargingRate;
    final DateTime createdAt;
    final DateTime updatedAt;

    ChargingBooth({
        required this.boothId,
        required this.boothName,
        required this.stationId,
        required this.status,
        required this.chargingRate,
        required this.createdAt,
        required this.updatedAt,
    });

    factory ChargingBooth.fromJson(Map<String, dynamic> json) => ChargingBooth(
        boothId: json["booth_id"],
        boothName: json["booth_name"],
        stationId: json["station_id"],
        status: json["status"],
        chargingRate: json["charging_rate"].toDouble(),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "booth_id": boothId,
        "booth_name": boothName,
        "station_id": stationId,
        "status": status,
        "charging_rate": chargingRate,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
