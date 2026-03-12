import 'package:gmap_cluster_manager/src/cluster_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ModifiedCluster<T extends ClusterItem> {
  final LatLng location;
  final List<T> items;

  ModifiedCluster({required this.location, required this.items});

  bool get isMultiple => items.length > 1;

  int get count => items.length;

  String getId() {
    final sorted = items.map((i) => (i as dynamic).id).toList()..sort();
    return sorted.join("|");
  }
}



 // String getId() {
  //   final sorted =
  //       items
  //           .map((i) => "${i.position.latitude},${i.position.longitude}")
  //           .toList()
  //         ..sort();

  //   return sorted.join("|");
  // }