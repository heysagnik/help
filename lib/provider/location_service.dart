import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationService {
  Position? _currentPosition;
  String? _currentAddress;
  Position? _nearestStation;
  String? _nearestStationAddress;

  Future<bool> handleLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return _currentPosition;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String?> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      _currentAddress = '${place.locality}, ${place.postalCode}';
      return _currentAddress;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<LatLng?> getNearestPoliceStation(Position position) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=7000&type=police&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['results'].isNotEmpty) {
        final place = jsonResponse['results'][0];
        final lat = place['geometry']['location']['lat'];
        final lng = place['geometry']['location']['lng'];
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  Position? get nearestStation => _nearestStation;
  String? get nearestStationAddress => _nearestStationAddress;
}
