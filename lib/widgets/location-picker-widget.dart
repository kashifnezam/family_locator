// widgets/location_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final LatLng? initialLocation;

  const LocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<List<LocationSuggestion>> _searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<LocationSuggestion> suggestions = [];

        for (final item in data) {
          try {
            suggestions.add(LocationSuggestion(
              displayName: item['display_name']?.toString() ?? 'Unknown location',
              lat: double.tryParse(item['lat']?.toString() ?? '0') ?? 0,
              lon: double.tryParse(item['lon']?.toString() ?? '0') ?? 0,
            ));
          } catch (e) {
            debugPrint('Error parsing location item: $e');
          }
        }

        return suggestions;
      }
      return [];
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TypeAheadField<LocationSuggestion>(
            controller: _searchController,
            focusNode: _searchFocusNode,
            debounceDuration: const Duration(milliseconds: 500),
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Search location',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              );
            },
            suggestionsCallback: _searchPlaces,
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(
                  suggestion.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },

            emptyBuilder: (context) => const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('No locations found'),
            ),
            loadingBuilder: (context) => const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            onSelected: (suggestion) {
              setState(() {
                _selectedLocation = LatLng(suggestion.lat, suggestion.lon);
                _mapController.move(_selectedLocation!, 15.0);
              });
              _searchController.text = suggestion.displayName;
            },
          ),
        ),
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? const LatLng(0, 0),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              minZoom: 0.2,
              initialRotation: 0,
              backgroundColor: Colors.blue.shade100,
              onTap: (_, latLng) {
                setState(() => _selectedLocation = latLng);
                _searchController.clear();
                _searchFocusNode.unfocus();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _selectedLocation!,
                      child:  const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedLocation == null
                    ? 'Tap on map or search to select location'
                    : 'Selected Location:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                _selectedLocation == null
                    ? 'Not selected'
                    : 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(3)}\n'
                    'Lng: ${_selectedLocation!.longitude.toStringAsFixed(3)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedLocation == null
                      ? null
                      : () {
                    widget.onLocationSelected(_selectedLocation!);
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm Location'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LocationSuggestion {
  final String displayName;
  final double lat;
  final double lon;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}