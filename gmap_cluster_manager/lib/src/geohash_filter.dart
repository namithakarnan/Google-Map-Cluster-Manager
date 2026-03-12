import 'package:gmap_cluster_manager/src/cluster_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeohashFilter<T extends ClusterItem> {
  List<T> filter(List<T> items, LatLngBounds bounds) {
    return items.where((item) {
      return bounds.contains(item.position);
    }).toList();
  }
}
