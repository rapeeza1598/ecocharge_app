import 'dart:convert';

WebsocketCommand websocketCommandFromJson(String str) => WebsocketCommand.fromJson(json.decode(str));

String websocketCommandToJson(WebsocketCommand data) => json.encode(data.toJson());

class WebsocketCommand {
    final String boothId;
    final String sessionsId;
    final String power;
    final String action;

    WebsocketCommand({
        required this.boothId,
        required this.sessionsId,
        required this.power,
        required this.action,
    });

    factory WebsocketCommand.fromJson(Map<String, dynamic> json) => WebsocketCommand(
        boothId: json["boothId"],
        sessionsId: json["sessionsId"],
        power: json["power"],
        action: json["action"],
    );

    Map<String, dynamic> toJson() => {
        "boothId": boothId,
        "sessionsId": sessionsId,
        "power": power,
        "action": action,
    };
}
