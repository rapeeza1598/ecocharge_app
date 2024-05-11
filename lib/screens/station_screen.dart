import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/stations.dart';

class StationScreen extends StatefulWidget {
  const StationScreen({super.key});

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  final dio = Dio();
  List<Stations> stations = [];
  final Geolocator myLocation = Geolocator();
  late final Position position;
  bool isLoading = false;
  @override
  void initState() {
    fetchStations();
    super.initState();
  }

  void fetchStations() async {
    try {
      getCurrentLocation();
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final response = await dio
          .get('https://ecocharge.azurewebsites.net/station/?skip=0&limit=100');
      final List<dynamic> responseData = response.data;
      setState(() {
        stations = responseData.map((e) => Stations.fromJson(e)).toList();
        isLoading = true;
      });
    } catch (e) {
      isLoading = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load stations: Please enable location service'),
        ),
      );
    }
    // position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // final response = await dio
    //     .get('https://ecocharge.azurewebsites.net/station/?skip=0&limit=100');
    // final List<dynamic> responseData = response.data;
    // setState(() {
    //   stations = responseData.map((e) => Stations.fromJson(e)).toList();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child:
            Padding(padding: const EdgeInsets.all(8.0), child: stationList()),
        onRefresh: () async {
          await Future.delayed(
            const Duration(seconds: 2),
            () {
              fetchStations();
            },
          );
        },
      ),
    );
  }

  Widget stationList() {
    if (!isLoading) {
      return
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
      );
    }
    if (isLoading && stations.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('No stations'),
          ),
        ],
      );
    }
    return ListView.builder(
      itemCount: stations.length,
      itemBuilder: (context, index) {
        // sort by distance
        stations.sort((a, b) => Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              a.location[0],
              a.location[1],
            ).compareTo(
              Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                b.location[0],
                b.location[1],
              ),
            ));
        return Card(
          child: ListTile(
            leading: const Icon(Icons.ev_station),
            title: Text(stations[index].name),
            subtitle: Text('Distance ${(Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  stations[index].location[0],
                  stations[index].location[1],
                ) / 1000).toStringAsFixed(2)} KM'),
            trailing: const Icon(Icons.directions),
            onTap: () {
              // print(stations[index].location[0]);
              // print(stations[index].location[1]);
              openMapWithRoute(
                stations[index].location[0],
                stations[index].location[1],
              );
              // openMapWithRoute(14.165208, 101.345586);
            },
          ),
        );
      },
    );
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> openMapWithRoute(double endLatitude, double endLongitude) async {
    Position currentPosition = await getCurrentLocation();
    String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&origin=${currentPosition.latitude},${currentPosition.longitude}&destination=$endLatitude,$endLongitude&travelmode=driving";

    try {
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not open the map.';
      }
    } catch (e) {
      print(e.toString());
      // Handle exception here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to launch Google Maps: $e'),
        ),
      );
    }
  }
}
