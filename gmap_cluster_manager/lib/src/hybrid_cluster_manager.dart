import 'package:gmap_cluster_manager/src/cluster_item.dart';
import 'package:gmap_cluster_manager/src/modified_cluster.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    hide Cluster;
import 'grid_algorithm.dart';
import 'geohash_filter.dart';

typedef MarkerBuilder<T extends ClusterItem> =
    Future<Marker> Function(ModifiedCluster<T> cluster);

class HybridClusterManager<T extends ClusterItem> {
  List<T> _items;

  final MarkerBuilder<T> markerBuilder;
  final void Function(Set<Marker>) updateMarkers;

  final GridClusterAlgorithm<T> _grid;
  final GeohashFilter<T> _filter;

  CameraPosition? _cameraPosition;
  Set<Marker> _currentMarkers = {};

  int? _mapId;

  HybridClusterManager(
    List<T> items, {
    required this.markerBuilder,
    required this.updateMarkers,
    double gridSize = 80,
    double? stopClusteringZoom,
  }) : _items = List<T>.from(items),
       _grid = GridClusterAlgorithm(
         gridSize: gridSize,
         stopClusteringZoom: stopClusteringZoom,
       ),
       _filter = GeohashFilter();

  void setMapId(int mapId) async {
    _mapId = mapId;

    final zoom = await GoogleMapsFlutterPlatform.instance.getZoomLevel(
      mapId: mapId,
    );

    _cameraPosition = CameraPosition(target: const LatLng(0, 0), zoom: zoom);

    updateMap();
  }

  void onCameraMove(CameraPosition position) {
    _cameraPosition = position;
    // updateMap();
  }

  void updateItems(List<T> items) {
    _items = List.from(items);
    updateMap();
  }

  Future<void> updateMap() async {
    if (_mapId == null || _cameraPosition == null) return;

    final bounds = await GoogleMapsFlutterPlatform.instance.getVisibleRegion(
      mapId: _mapId!,
    );

    /// 1️⃣ Geohash / spatial filtering
    final filtered = _filter.filter(_items, bounds);

    /// 2️⃣ Grid clustering
    final clusters = _grid.cluster(filtered, _cameraPosition!.zoom);

    final markers = await _buildMarkers(clusters);

    if (!_sameMarkers(markers, _currentMarkers)) {
      _currentMarkers = markers;
      updateMarkers(markers);
    }
  }

  Future<Set<Marker>> _buildMarkers(List<ModifiedCluster<T>> clusters) async {
    final Set<Marker> markers = {};

    for (final cluster in clusters) {
      final marker = await markerBuilder(cluster);
      markers.add(marker);
    }

    return markers;
  }

  bool _sameMarkers(Set<Marker> a, Set<Marker> b) {
    if (a.length != b.length) return false;

    final ids = b.map((m) => m.markerId.value).toSet();

    return a.every((m) => ids.contains(m.markerId.value));
  }
}
