import 'dart:convert';

Topup topupFromJson(String str) => Topup.fromJson(json.decode(str));

String topupToJson(Topup data) => json.encode(data.toJson());

class Topup {
    final String imageBase64;
    final int amount;

    Topup({
        required this.imageBase64,
        required this.amount,
    });

    factory Topup.fromJson(Map<String, dynamic> json) => Topup(
        imageBase64: json["image_base64"],
        amount: json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "image_base64": imageBase64,
        "amount": amount,
    };
}