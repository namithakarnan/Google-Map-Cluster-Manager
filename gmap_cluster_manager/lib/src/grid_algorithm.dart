import 'dart:math';
import 'package:gmap_cluster_manager/gmap_cluster_manager.dart';
import 'package:gmap_cluster_manager/src/cluster_item.dart';
import 'package:gmap_cluster_manager/src/modified_cluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GridClusterAlgorithm<T extends ClusterItem> {
  final double gridSize;
  final double? stopClusteringZoom;

  GridClusterAlgorithm({this.gridSize = 80, this.stopClusteringZoom});

  List<ModifiedCluster<T>> cluster(List<T> items, double zoom) {
    if (stopClusteringZoom != null && zoom >= stopClusteringZoom!) {
      return items
          .map((i) => ModifiedCluster(location: i.position, items: [i]))
          .toList();
    }

    final Map<String, List<T>> grid = {};

    for (final item in items) {
      final p = _project(item.position, zoom);

      final int x = (p.x / gridSize).floor();
      final int y = (p.y / gridSize).floor();

      final key = "$x:$y";

      grid.putIfAbsent(key, () => []);
      grid[key]!.add(item);
    }

    return grid.values.map((group) {
      return ModifiedCluster(location: _center(group), items: group);
    }).toList();
  }

  _Point _project(LatLng latLng, double zoom) {
    final siny = sin(latLng.latitude * pi / 180);
    final scale = 256 * pow(2, zoom);

    final x = scale * (0.5 + latLng.longitude / 360);
    final y = scale * (0.5 - log((1 + siny) / (1 - siny)) / (4 * pi));

    return _Point(x.toDouble(), y.toDouble());
  }

  LatLng _center(List<T> items) {
    double lat = 0;
    double lng = 0;

    for (final i in items) {
      lat += i.position.latitude;
      lng += i.position.longitude;
    }

    return LatLng(lat / items.length, lng / items.length);
  }
}

class _Point {
  final double x;
  final double y;

  _Point(this.x, this.y);
}
