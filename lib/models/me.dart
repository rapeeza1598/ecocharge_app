import 'dart:convert';

Me meFromJson(String str) => Me.fromJson(json.decode(str));

String meToJson(Me data) => json.encode(data.toJson());

class Me {
    String id;
    String firstName;
    String lastName;
    double balance;
    String email;
    String phoneNumber;
    String role;
    bool isActive;
    bool isVerify;
    DateTime createdAt;

    Me({
        required this.id,
        required this.firstName,
        required this.lastName,
        required this.balance,
        required this.email,
        required this.phoneNumber,
        required this.role,
        required this.isActive,
        required this.isVerify,
        required this.createdAt,
    });

    factory Me.fromJson(Map<String, dynamic> json) => Me(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        balance: json["balance"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        role: json["role"],
        isActive: json["is_active"],
        isVerify: json["is_verify"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "balance": balance,
        "email": email,
        "phoneNumber": phoneNumber,
        "role": role,
        "is_active": isActive,
        "is_Verify": isVerify,
        "created_at": createdAt.toIso8601String(),
    };
}