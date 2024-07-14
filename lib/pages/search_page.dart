import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../map_config/map_utils.dart';
import '../utils/location_utils.dart';
import '../widgets/search_results_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  bool _isSearching = false;
  String _searchText = "";
  List<dynamic> _searchResults = [];
  LatLng _center = const LatLng(18.55173625, 73.82375839545352);
  double _zoom = 9.6;
  LatLng? _markerPosition;
  LatLng? _currentLocation;
  bool _isSearchLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    LocationUtils.getCurrentLocation(
      onLocationLoaded: (location) {
        print("-------$location-------");
        setState(() {
          _currentLocation = location;
          _center = location;
          _zoom = 15;
          _mapController.move(_center, _zoom);
        });
      },
      onError: (error) {
        print("Error getting location: $error");
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text != _searchText) {
        setState(() {
          _searchText = _searchController.text;
          _searchLocations(_searchText);
        });
      }
    });
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty || query.length < 4) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearchLoading = true);

    try {
      List<dynamic> results = await searchPlace(query);
      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
      });
    } catch (e) {
      print("Error searching locations: $e");
      setState(() => _isSearchLoading = false);
      Get.defaultDialog(
        title: "Failed to search locations",
        onConfirm: () {
          Get.back();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text('Flutter Search with Map'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
                _searchResults = [];
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              minZoom: 5,
              maxZoom: 22,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentLocation!,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                  if (_markerPosition != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _markerPosition!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  const Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(28.61, 77.36),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    strokeWidth: 2,
                    pattern: StrokePattern.dashed(segments: const [10, 10]),
                    points: [
                      const LatLng(28.61, 77.36),
                      _center,
                      const LatLng(28.61, 77.36)
                    ],
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          if (_isSearching && _searchText.length > 3)
            SearchResultsList(
              searchResults: _searchResults,
              isLoading: _isSearchLoading,
              onResultTapped: (result) {
                final lat = double.parse(result['lat']);
                final lon = double.parse(result['lon']);
                final newCenter = LatLng(lat, lon);

                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchResults = [];
                  _center = newCenter;
                  _zoom = 15;
                  _markerPosition = newCenter;
                });

                _mapController.move(newCenter, _zoom);
              },
            ),
        ],
      ),
    );
  }
}
