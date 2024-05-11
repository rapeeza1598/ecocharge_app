import 'dart:convert';

ChargingSession chargingSessionFromJson(String str) =>
    ChargingSession.fromJson(json.decode(str));

String chargingSessionToJson(ChargingSession data) =>
    json.encode(data.toJson());

class ChargingSession {
  final double powerUsed;
  final DateTime startTime;
  final String id;
  final String userId;
  final DateTime endTime;
  final String boothId;
  final String status;

  ChargingSession({
    required this.powerUsed,
    required this.startTime,
    required this.id,
    required this.userId,
    required this.endTime,
    required this.boothId,
    required this.status,
  });

  factory ChargingSession.fromJson(Map<String, dynamic> json) =>
      ChargingSession(
        powerUsed: json["powerUsed"]?.toDouble(),
        startTime: DateTime.parse(json["startTime"]),
        id: json["id"],
        userId: json["userId"],
        endTime: DateTime.parse(json["endTime"]),
        boothId: json["booth_id"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "powerUsed": powerUsed,
        "startTime": startTime.toIso8601String(),
        "id": id,
        "userId": userId,
        "endTime": endTime.toIso8601String(),
        "booth_id": boothId,
        "status": status,
      };
}
