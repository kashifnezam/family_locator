import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (kIsWeb) {
  //   runApp(WebApp());
  // } else {
  //   await dotenv.load(fileName: ".env");
  //    runApp(MyApp());
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OSMViewer(
      controller: SimpleMapController(
        initPosition: GeoPoint(
          latitude: 47.4358055,
          longitude: 8.4737324,
        ),
        markerHome: const MarkerIcon(
          icon: Icon(Icons.home),
        ),
      ),
      zoomOption: const ZoomOption(
        initZoom: 16,
        minZoomLevel: 11,
      ),
    );
  }
}
