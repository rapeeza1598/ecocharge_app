import 'dart:convert';

List<History> historyFromJson(String str) => List<History>.from(json.decode(str).map((x) => History.fromJson(x)));

String historyToJson(List<History> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class History {
    final DateTime startTime;
    final String id;
    final double powerUsed;
    final String userId;
    final DateTime endTime;
    final String boothId;
    final String status;
    final String boothName;

    History({
        required this.startTime,
        required this.id,
        required this.powerUsed,
        required this.userId,
        required this.endTime,
        required this.boothId,
        required this.status,
        required this.boothName,
    });

    factory History.fromJson(Map<String, dynamic> json) => History(
        startTime: DateTime.parse(json["startTime"]),
        id: json["id"],
        powerUsed: json["powerUsed"]?.toDouble(),
        userId: json["userId"],
        endTime: DateTime.parse(json["endTime"]),
        boothId: json["booth_id"],
        status: json["status"],
        boothName: json["booth_name"],
    );

    Map<String, dynamic> toJson() => {
        "startTime": startTime.toIso8601String(),
        "id": id,
        "powerUsed": powerUsed,
        "userId": userId,
        "endTime": endTime.toIso8601String(),
        "booth_id": boothId,
        "status": status,
        "booth_name": boothName,
    };
}
