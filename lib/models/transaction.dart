import 'dart:convert';

List<Transaction> transactionFromJson(String str) => List<Transaction>.from(json.decode(str).map((x) => Transaction.fromJson(x)));

String transactionToJson(List<Transaction> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Transaction {
    final String id;
    final String userId;
    final String firstName;
    final String lastName;
    final String email;
    final double amount;
    final String transactionType;
    final String description;
    final DateTime createdAt;

    Transaction({
        required this.id,
        required this.userId,
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.amount,
        required this.transactionType,
        required this.description,
        required this.createdAt,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        userId: json["userId"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        amount: json["amount"],
        transactionType: json["transactionType"],
        description: json["description"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "amount": amount,
        "transactionType": transactionType,
        "description": description,
        "created_at": createdAt.toIso8601String(),
    };
}
