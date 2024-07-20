import 'dart:async';
import 'package:family_locator/api/firebase_api.dart';
import 'package:family_locator/models/anonymous_model.dart';
import 'package:family_locator/models/user_model.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/utils/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../api/map_utils.dart';
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
  bool _hideTools = false;
  String _searchText = "";
  List<dynamic> _searchResults = [];
  LatLng _center = const LatLng(28.6, 77.36);
  double _zoom = 5;
  LatLng? _markerPosition;
  LatLng? _currentLocation;
  bool _isSearchLoading = false;
  Timer? _debounce;
  bool isLocPer = false;

  @override
  initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    setState(() {
      isLocPer = true;
    });

    LocationUtils.getCurrentLocation(
      onLocationLoaded: (location) {
        print("-------$location-------");
        setState(() {
          _currentLocation = location;
          _center = location;
          _zoom = 15;

          setState(() {
            isLocPer = false;
          });
        });
      },
      onError: (error) {
        print("Error getting location: $error");
        setState(() {
          isLocPer = false;
        });
      },
      onStartMoving: () {
        AppConstants.log.i("Person Starts Moving");
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

  getDetails() async {
    AppConstants.log.i(await LocationUtils.getMacAddress());
    String ip = LocationUtils.getLocalIPAddress().toString();
    AppConstants.log.i(ip);
    await LocationUtils.getDeviceId().then((e) {
      AppConstants.log.i(e);
      FirebaseApi.addDataIfNotExists(
          "anonymopus",
          "123456",
          AnonymousModel(
            currLoc: _currentLocation.toString(),
            groupId: ['1234'],
            id: e,
            ipAddress: ip,
            name: "munna",
            
          ));
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
      appBar: _isSearching
          ? AppBar(
              title: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.close),
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
            )
          : null,
      body: Stack(
        children: [
          const Icon(Icons.search),
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
            ),
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hideTools = !_hideTools;
                  });
                },
                child: TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
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
          if (!_isSearching && _hideTools)
            Container(
              margin: const EdgeInsets.only(top: 35, left: 10),
              child: IconButton(
                icon: const Icon(
                  Icons.search,
                  size: 50,
                ),
                onPressed: () async {
                  setState(() {
                    if (_isSearching) {
                      _searchController.clear();
                    }
                    _isSearching = !_isSearching;
                    _searchResults = [];
                  });
                  AppConstants.log.d(await FirebaseApi.addDataToDocument(
                      "user",
                      FirebaseAuth.instance.currentUser!.uid.toString(),
                      UserModel(
                          currLoc: _currentLocation.toString(),
                          name: "Kashif Don")));
                },
              ),
            ),
          if (_hideTools)
            Container(
              margin: EdgeInsets.only(top: 35, left: Get.width - 100),
              child: IconButton(
                icon: const Icon(
                  Icons.chat,
                  size: 30,
                ),
                onPressed: () {
                  //  Get.to(() => const MyData());
                  getDetails();
                },
              ),
            ),
          if (isLocPer) DialogUtil.buildCircularProgressIndicator(),
        ],
      ),
    );
  }
}
