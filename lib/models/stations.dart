import 'dart:convert';

List<Stations> stationsFromJson(String str) => List<Stations>.from(json.decode(str).map((x) => Stations.fromJson(x)));

String stationsToJson(List<Stations> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Stations {
    String id;
    String name;
    List<double> location;
    DateTime createdAt;

    Stations({
        required this.id,
        required this.name,
        required this.location,
        required this.createdAt,
    });

    factory Stations.fromJson(Map<String, dynamic> json) => Stations(
        id: json["id"],
        name: json["name"],
        location: List<double>.from(json["location"].map((x) => x?.toDouble())),
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "location": List<dynamic>.from(location.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
    };
}