import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gmap_cluster_manager/gmap_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class TestMarker implements ClusterItem {
  final String id;

  @override
  final LatLng position;

  TestMarker(this.id, this.position);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MapPage());
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late HybridClusterManager<TestMarker> _manager;

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    final items = _generateMarkers(500);

    _manager = HybridClusterManager<TestMarker>(
      items,
      markerBuilder: _buildMarker,
      updateMarkers: (m) {
        setState(() {
          markers = m;
        });
      },
    );
  }

  List<TestMarker> _generateMarkers(int count) {
    final random = Random();

    const baseLat = 13.0827;
    const baseLng = 80.2707;

    return List.generate(count, (i) {
      final lat = baseLat + (random.nextDouble() - 0.5) * 0.2;
      final lng = baseLng + (random.nextDouble() - 0.5) * 0.2;

      return TestMarker("id_$i", LatLng(lat, lng));
    });
  }

  Future<Marker> _buildMarker(ModifiedCluster<TestMarker> cluster) async {
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        cluster.isMultiple ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
      ),
      infoWindow: InfoWindow(
        title: cluster.isMultiple ? "Cluster (${cluster.count})" : "Marker",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cluster Test")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.0827, 80.2707),
          zoom: 10,
        ),
        markers: markers,
        onMapCreated: (controller) {
          _manager.setMapId(controller.mapId);
        },
        onCameraMove: (pos) {
          _manager.onCameraMove(pos);
        },
        onCameraIdle: () {
          _manager.updateMap();
        },
      ),
    );
  }
}
