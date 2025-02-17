import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  LatLng _userLocation =
      LatLng(0, 0); // Default location until real location is fetched
  bool _isLocationFetched = false; // Flag to check if the location is fetched

  // Initialize Google Places API
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: dotenv.env['GOOGLE_API_KEY']!);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Get the user's current location
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLocationFetched = true; // Mark location as fetched
      });
      _getNearbyPharmacies(_userLocation.latitude, _userLocation.longitude);
    } catch (e) {
      //error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching location: $e')));
    }
  }

  // Fetch nearby pharmacies using Google Places API
  Future<void> _getNearbyPharmacies(double latitude, double longitude) async {
    try {
      // Create a Location object for the user's location
      Location location = Location(lat: latitude, lng: longitude);

      PlacesSearchResponse response = await _places.searchNearbyWithRadius(
        location,
        5000, // Radius in meters
        type: 'pharmacy', // Searching for pharmacies
      );

      if (response.status == 'OK') {
        for (var result in response.results) {
          setState(() {
            _markers.add(Marker(
              markerId: MarkerId(result.placeId),
              position: LatLng(
                  result.geometry!.location.lat, result.geometry!.location.lng),
              infoWindow:
                  InfoWindow(title: result.name, snippet: result.vicinity),
            ));
          });
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load pharmacies')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching pharmacies: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Pharmacies')),
      body: _isLocationFetched
          ? GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _userLocation,
                zoom: 14,
              ),
              markers: _markers,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
