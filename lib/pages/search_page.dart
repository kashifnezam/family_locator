// import 'dart:async';
// import 'package:family_locator/api/save_data.dart';
// import 'package:family_locator/pages/room_dialogue.dart';
// import 'package:family_locator/utils/constants.dart';
// import 'package:family_locator/utils/device_info.dart';
// import 'package:family_locator/utils/offline_data.dart';
// import 'package:family_locator/widgets/button_widget.dart';
// import 'package:family_locator/widgets/username_dialogue.dart';
// import 'package:family_locator/widgets/custom_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:get/get.dart';
// import 'package:latlong2/latlong.dart';
// import '../api/firebase_api.dart';
// import '../api/map_utils.dart';
// import '../utils/location_utils.dart';
// import '../widgets/search_results_list.dart';

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   SearchPageState createState() => SearchPageState();
// }

// class SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
//   final MapController _mapController = MapController();

//   bool _isSearching = false;
//   bool _hideTools = false;
//   String _searchText = "";
//   List<dynamic> _searchResults = [];
//   LatLng _center = const LatLng(28.6, 77.36);
//   double _zoom = 5;
//   LatLng? _markerPosition;
//   LatLng? _currentLocation;
//   bool _isSearchLoading = false;
//   Timer? _debounce;
//   bool isLocPer = false;

//   @override
//   initState() {
//     super.initState();

//     _searchController.addListener(_onSearchChanged);
//     isLocPer = false;

//     LocationUtils.getCurrentLocation(
//       onLocationLoaded: (location) {
//         _currentLocation = location;
//         _center = location;
//         _zoom = 15;
//         isLocPer = false;
//       },
//       onError: (error) {
//         AppConstants.log.e("Error getting location: $error");
//         isLocPer = false;
//       },
//       onStartMoving: () {
//         AppConstants.log.i("Person Starts Moving");
//         if (DeviceInfo.deviceId != null) {
//           FirebaseApi.updateLocation(
//               _currentLocation.toString(), DeviceInfo.deviceId!);
//         }
//       },
//     );
//     saveUserData();
//   }

//   Future<void> saveUserData() async {
//     await DeviceInfo.getDetails().then((x) {
//       SaveDataApi.saveAnonymousData(DeviceInfo.deviceId, DeviceInfo.macAddress,
//           DeviceInfo.ipAddress);
//     });
//   }

//   void _onSearchChanged() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 1500), () {
//       if (_searchController.text != _searchText) {
//         _searchText = _searchController.text;
//         _searchLocations(_searchText);
//       }
//     });
//   }

//   Future<void> _searchLocations(String query) async {
//     if (query.isEmpty || query.length < 4) {
//       _searchResults = [];
//       return;
//     }

//     _isSearchLoading = true;

//     try {
//       List<dynamic> results = await searchPlace(query);
//       _searchResults = results;
//       _isSearchLoading = false;
//     } catch (e) {
//       AppConstants.log.e("Error searching locations: $e");
//       _isSearchLoading = false;
//       Get.defaultDialog(
//         title: "Failed to search locations",
//         onConfirm: () {
//           Get.back();
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _isSearching
//           ? AppBar(
//               title: TextField(
//                 controller: _searchController,
//                 style: const TextStyle(color: Colors.black),
//                 decoration: const InputDecoration(
//                   hintText: 'Search...',
//                   hintStyle: TextStyle(color: Colors.black),
//                   border: InputBorder.none,
//                 ),
//               ),
//               actions: <Widget>[
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () {
//                     setState(() {
//                       if (_isSearching) {
//                         _searchController.clear();
//                       }
//                       _isSearching = !_isSearching;
//                       _searchResults = [];
//                     });
//                   },
//                 ),
//               ],
//             )
//           : null,
//       body: Stack(
//         children: [
//           const Icon(Icons.search),
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               cameraConstraint:
//                   CameraConstraint.contain(bounds: MapConstants.maxBounds),
//               initialCenter: _center,
//               initialZoom: _zoom,
//             ),
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _hideTools = !_hideTools;
//                   });
//                 },
//                 child: TileLayer(
//                   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 ),
//               ),
//               MarkerLayer(
//                 markers: [
//                   if (_currentLocation != null)
//                     Marker(
//                       width: 80.0,
//                       height: 80.0,
//                       point: _currentLocation!,
//                       child: const Icon(
//                         Icons.my_location,
//                         color: Colors.blue,
//                         size: 40.0,
//                       ),
//                     ),
//                   if (_markerPosition != null)
//                     Marker(
//                       width: 80.0,
//                       height: 80.0,
//                       point: _markerPosition!,
//                       child: const Icon(
//                         Icons.location_on,
//                         color: Colors.red,
//                         size: 40.0,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//           if (_isSearching && _searchText.length > 3)
//             SearchResultsList(
//               searchResults: _searchResults,
//               isLoading: _isSearchLoading,
//               onResultTapped: (result) {
//                 final lat = double.parse(result['lat']);
//                 final lon = double.parse(result['lon']);
//                 final newCenter = LatLng(lat, lon);

//                 setState(() {
//                   _isSearching = false;
//                   _searchController.clear();
//                   _searchResults = [];
//                   _center = newCenter;
//                   _zoom = 15;
//                   _markerPosition = newCenter;
//                 });

//                 _mapController.move(newCenter, _zoom);
//               },
//             ),
//           if (!_isSearching)
//             Container(
//               margin: const EdgeInsets.only(top: 35, left: 10),
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.search,
//                   size: 50,
//                 ),
//                 onPressed: () async {
//                   setState(() {
//                     if (_isSearching) {
//                       _searchController.clear();
//                     }
//                     _isSearching = !_isSearching;
//                     _searchResults = [];
//                   });
//                 },
//               ),
//             ),
//           if (!_isSearching)
//             Padding(
//               padding: EdgeInsets.only(
//                   top: AppConstants.height * 0.1,
//                   left: AppConstants.width * 0.25),
//               child: GestureDetector(
//                 onTap: () async {
//                   String? usr = await OfflineData.getData("usr");
//                   if (usr != null) {
//                     String? dateString = await OfflineData.getData("date");
//                     if (dateString != null) {
//                       DateTime date = DateTime.parse(dateString);
//                       if (DateTime.now()
//                           .isAfter(date.add(const Duration(days: 7)))) {
//                         usr = null;
//                       }
//                     }
//                   }
//                   usr != null
//                       ? Get.dialog(RoomDialog())
//                       : Get.dialog(UsernameDialog());
//                 },
//                 child: ButtonWidget.elevatedBtn("Family Room"),
//               ),
//             ),

//           // Here is Circle Progress when the location gets load
//           if (isLocPer) CustomWidget.buildCircularProgressIndicator(),
//         ],
//       ),
//     );
//   }
// }
