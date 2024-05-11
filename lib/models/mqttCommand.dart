import 'dart:convert';

MqttCommand mqttCommandFromJson(String str) => MqttCommand.fromJson(json.decode(str));

String mqttCommandToJson(MqttCommand data) => json.encode(data.toJson());

class MqttCommand {
    final String boothId;
    final String sessionsId;
    final double money;
    final String command;

    MqttCommand({
        required this.boothId,
        required this.sessionsId,
        required this.money,
        required this.command,
    });

    factory MqttCommand.fromJson(Map<String, dynamic> json) => MqttCommand(
        boothId: json["boothId"],
        sessionsId: json["sessionsId"],
        // to double
        money: double.parse(json["money"]),
        command: json["command"],
    );

    Map<String, dynamic> toJson() => {
        "boothId": boothId,
        "sessionsId": sessionsId,
        "money": money,
        "command": command,
    };
}
