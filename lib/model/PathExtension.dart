import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';

extension PathWKTExtension on Path<LatLng> {
  String get wkt =>  'LINESTRING(${coordinates.map((e) => '${e.longitude.toString()} ${e.latitude.toString()}').join(",")})';

  LatLngBounds get bounds {
    double minLat = 1000.0;
    double minLon = 1000.0;
    double maxLat = -1000.0;
    double maxLon = -1000.0;


    coordinates.forEach((c) {
      minLat = min(minLat, c.latitude);
      minLon = min(minLon, c.longitude);
      maxLat = max(maxLat, c.latitude);
      maxLon = max(maxLon, c.longitude);
    });

    return LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon));

  }
}

extension LatLngBoundsExtension on LatLngBounds {

  String  asString() {
    return "${southWest!.latitude} ${southWest!.longitude} - ${northEast!.latitude} ${northEast!.longitude}";
  }
}

