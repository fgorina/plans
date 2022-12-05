import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart'; // Suitable for most situations
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:gpx/gpx.dart';
import 'package:plans/model/PathExtension.dart';
import '/model/AppStateModel.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:location/location.dart';
import '/Meteocat/POI.dart';
import '/PlusMinusWidget.dart';
import 'package:pull_down_button/pull_down_button.dart';
import '/Maps/MapsUtilities.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:async';
import '/model/SQLDatabase.dart';

extension MyLatLngBounds on LatLngBounds {
  String get wkt =>
      'POLYGON((${this.northWest.longitude.toString()} ${this.northWest.latitude.toString()},' +
      '${this.northEast!.longitude.toString()} ${this.northEast!.latitude.toString()},' +
      '${this.southEast.longitude.toString()} ${this.southEast.latitude.toString()},' +
      '${this.southWest!.longitude.toString()} ${this.southWest!.latitude.toString()},'
          '${this.northWest.longitude.toString()} ${this.northWest.latitude.toString()}' +
      '))';
}

class PopupPoiWidget extends StatefulWidget {
  final PoiMarker marker;
  final Function close;

  PopupPoiWidget(this.marker, this.close);

  _PopupPoiWidgetState createState() {
    return _PopupPoiWidgetState(marker, close);
  }
}

class _PopupPoiWidgetState extends State<PopupPoiWidget> {
  static List<Color> beaufortColors = [
    Color.fromRGBO(134, 163, 171, 1.0),
    Color.fromRGBO(134, 163, 171, 1.0),
    Color.fromRGBO(126, 152, 187, 1.0),
    Color.fromRGBO(110, 144, 208, 1.0),
    Color.fromRGBO(15, 147, 167, 1.0),
    Color.fromRGBO(57, 162, 57, 1.0),
    Color.fromRGBO(194, 134, 62, 1.0),
    Color.fromRGBO(199, 66, 13, 1.0),
    Color.fromRGBO(209, 0, 50, 1.0),
    Color.fromRGBO(175, 80, 136, 1.0),
    Color.fromRGBO(117, 74, 146, 1.0),
    Color.fromRGBO(69, 105, 141, 1.0),
    Color.fromRGBO(195, 251, 118, 1.0),
  ];

  static List<Color> douglasColors = [
    Color.fromRGBO(134, 163, 171, 1.0),
    Color.fromRGBO(126, 152, 187, 1.0),
    Color.fromRGBO(110, 144, 208, 1.0),
    Color.fromRGBO(57, 162, 57, 1.0),
    Color.fromRGBO(194, 134, 62, 1.0),
    Color.fromRGBO(209, 0, 50, 1.0),
    Color.fromRGBO(175, 80, 136, 1.0),
    Color.fromRGBO(117, 74, 146, 1.0),
    Color.fromRGBO(69, 105, 141, 1.0),
    Color.fromRGBO(195, 251, 118, 1.0),
  ];

  final PoiMarker marker;
  final Function close;

  _PopupPoiWidgetState(this.marker, this.close);

  @override
  Widget build(BuildContext context) {
    {
      // Get date and time

      DateFormat df = DateFormat("dd/MM HH:mm");

      var now = DateTime.now();
      if (widget.marker.poi.dades.isEmpty &&
          widget.marker.poi.state == PoiState.notLoading) {
        widget.marker.poi.load().whenComplete(() {
          setState(() {});
        });
      }

      //WeatherCondition weather = widget.marker.poi.weatherNearestTo(now)!;
      //String ds = df.format(weather.data!);

      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: CupertinoColors.white),
        width: 250,
        height: 200,
        padding: EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => close(this.marker),
          child: Column(children: [
            marker.poi.info!.nom.text.make(),
            Divider(),
            SizedBox(
              height: 140,
              child: marker.poi.dades.isEmpty
                  ? Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: marker.poi.weatherFrom(now).map((e) {
                          return Row(children: [
                            Container(
                                width: 80,
                                child: df
                                    .format(e.data!)
                                    .text
                                    .size(12)
                                    .start
                                    .make()),
                            Container(
                                width: 60,
                                color: _PopupPoiWidgetState
                                    .beaufortColors[beaufort(e.velocitatVent!)],
                                child: (((e.velocitatVent!) * 3.6)
                                            .toStringAsFixed(0) +
                                        " km/h")
                                    .text
                                    .size(12)
                                    .end
                                    .make()),
                            Icon(windIcon(e.direccioVent!),
                                size: 12, color: Colors.black),
                            Container(
                                width: 60,
                                color: _PopupPoiWidgetState
                                    .douglasColors[beaufort(e.alturaOna!)],
                                child: (e.alturaOna!
                                            .max(0.0)
                                            .min(10.0)
                                            .toStringAsFixed(2) +
                                        " m")
                                    .toString()
                                    .text
                                    .size(12)
                                    .end
                                    .make()),
                            Icon(windIcon(e.direccioOna! + 180.0),
                                size: 12, color: Colors.black),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ]),
        ),
      );
    }
  }
}

class PoiMarker extends Marker {
  late final POI poi;

  PoiMarker(POI somepoi,
      {required LatLng point,
      required WidgetBuilder builder,
      Key? key,
      double width = 30.0,
      double height = 30.0,
      bool? rotate,
      Offset? rotateOrigin,
      AlignmentGeometry? rotateAlignment,
      AnchorPos? anchorPos})
      : super(
            point: somepoi.info!.coordenades,
            builder: builder,
            key: key,
            width: width,
            height: height,
            rotate: rotate,
            rotateOrigin: rotateOrigin,
            rotateAlignment: rotateAlignment,
            anchorPos: anchorPos) {
    poi = somepoi;
  }

  Widget buildPopup(BuildContext context, Function close) {
    return PopupPoiWidget(this, close);
  }
}

class MapViewOptions {
  bool search = false;
  bool weather = false;

  MapViewOptions(this.search, this.weather);
}

class MapView extends StatefulWidget {
  AppStateModel model;
  SQLDatabase db;
  MapViewOptions options;

  MapView(this.model, this.db, this.options);

  @override
  _MapViewState createState() {
    return _MapViewState();
  }
}

class _MapViewState extends State<MapView> {
  Location? _location = Location();
  StreamSubscription? _locationSubscription;
  StreamSubscription? _compassSubscription;

  LatLng? myLocation;
  double? myHeading;

  double myZoom = 13.0;

  final mapController = MapController();
  bool _showMapPicker = false;
  bool _loadingPlatges = false;
  bool _centerAlways = false;
  bool _mapReady = false;

  List<Marker> _markers = [];
  final PopupController _popupController = PopupController();

  bool isDesktop = !(Platform.isAndroid || Platform.isIOS);

  _MapViewState();

  @override
  void dispose() {


    if (_compassSubscription != null) {
      _compassSubscription!.cancel();
      _compassSubscription = null;
    }
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
      _locationSubscription = null;
    }
    super.dispose();
  }

  double mapRotation() {
    if (_mapReady) {
      return mapController.rotation;
    } else {
      return 0.0;
    }
  }

  void closePopup(Marker mk) {
    _popupController.hidePopupsOnlyFor([mk]);
  }

  Future loadPlatges({bool force = false}) async {
    setState(() {
      _loadingPlatges = true;
    });

    if (POI.platges.isEmpty || force) {
      await POI.loadPlatges();
    }

    // Add far away to the map
    _markers = [];
    POI.marEndins.forEach((element) {
      _markers.add(PoiMarker(
        element,
        point: element.info!.coordenades,
        builder: (context) => const Icon(
          CupertinoIcons.circle,
          color: CupertinoColors.systemRed,
        ),
      ));
    });

    POI.platges.forEach((element) {
      _markers.add(PoiMarker(
        element,
        point: element.info!.coordenades,
        builder: (context) => const Icon(
          CupertinoIcons.circle,
          color: CupertinoColors.systemRed,
        ),
      ));
    });

    setState(() {
      _loadingPlatges = false;
    });
  }

  Future initLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    if (_location == null) {
      return;
    }

    print("Init Location");
    _serviceEnabled = await _location!.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location!.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location!.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location!.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    var aLocation = await _location!.getLocation();
    myLocation = LatLng(aLocation.latitude!, aLocation.longitude!);
    myZoom = mapController.zoom;
    ;
    _locationSubscription =
        _location!.onLocationChanged.listen((LocationData currentLocation) {
      processLocation(currentLocation);
    });

    _compassSubscription = FlutterCompass.events!.listen((event) {
      setState(() {
        myHeading = event.heading;
        //print("New Heading $myHeading");
        if (_centerAlways && myHeading != null && myLocation != null) {
          mapController.moveAndRotate(myLocation!, myZoom, 360.0 - myHeading!);
        }
      });
    });
  }

  void processLocation(LocationData data) async {
    myLocation = LatLng(data.latitude!, data.longitude!);
    myZoom = mapController.zoom;

    if (_centerAlways) {
      if (myHeading != null) {
        mapController.moveAndRotate(
            myLocation!, mapController.zoom, 360.0 - myHeading!);
      } else {
        mapController.move(myLocation!, myZoom);
      }
    }
  }

  void getLocation() async {
    if (myLocation != null) {
      mapController.move(
        myLocation!,
        mapController.zoom,
      );
    }
  }

  void toggleMapPicker() async {
    setState(() {
      _showMapPicker = !_showMapPicker;
    });
  }

  Future centerRoute(AppStateModel model) async {
    if (model.route.nrOfCoordinates > 0) {
      var bounds = model.route.bounds;

      var fitBounds = mapController.centerZoomFitBounds(bounds,
          options: FitBoundsOptions(padding: EdgeInsets.all(20.0)));
      myZoom = fitBounds.zoom;

      mapController.moveAndRotate(fitBounds.center, myZoom, 0.0);
    }
  }

  void intersect() async {
    var bounds = mapController.bounds!.wkt;

    var itineraris =
        await widget.db.customSearch("itineraris", "intersect", bounds);

    itineraris.forEach((element) {
      print(element["nom"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    var _selectedItem = 0;

    return CupertinoPageScaffold(

      backgroundColor: context.canvasColor,
      child: SafeArea(
        child: Consumer<AppStateModel>(
          builder: (context, model, child) {
            var stk = [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  onMapReady: () async {
                    _mapReady = true;
                    await initLocation();
                    await loadPlatges();
                    await centerRoute(model);
                  },
                  onPositionChanged: (position, getures) {
                    if (position.center! != myLocation) {
                      setState(() {
                        myZoom = position.zoom ?? myZoom;
                        _centerAlways = false;
                      });
                    }
                  },
                  center: LatLng(51.5, -0.09),
                  zoom: 13.0,
                  onTap: (pos, latlon) {
                    model.addToRoute(latlon);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: model.currentMap.schema,
                    tileProvider: FMTC
                        .instance(model.currentMap.cache)
                        .getTileProvider(FMTCTileProviderSettings(
                            behavior: CacheBehavior.cacheFirst)),
                    // additionalOptions: {
                    //   "apikey": "ab2214500d754861bbd9f8c785b6eb0d",
                    //},
                    userAgentPackageName: 'es.gorina.plans',
                  ),
                  //MarkerLayer(markers: markers),
                  /*
                  TileLayer(
                    urlTemplate: model.openSeaMap.schema,
                    tileProvider: FMTC
                        .instance(model.openSeaMap.cache)
                        .getTileProvider(FMTCTileProviderSettings(
                            behavior: CacheBehavior.cacheFirst)),
                    // additionalOptions: {
                    //   "apikey": "ab2214500d754861bbd9f8c785b6eb0d",
                    //},
                    userAgentPackageName: 'es.gorina.plans',
                    backgroundColor: Color(0x00E0E0E0),
                  ),
                  */

                  PolylineLayer(
                    // Must be before MarkerClusterLayer or it blocks taps to markers.
                    polylines: [
                      Polyline(
                          color: CupertinoColors.systemRed,
                          borderStrokeWidth: 2.0,
                          points: model.route.coordinates),
                    ],
                  ),

                  MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                    markers: model.showPlatges && widget.options.weather
                        ? _markers
                        : [],
                    showPolygon: false,
                    polygonOptions: PolygonOptions(
                        borderColor: CupertinoColors.activeBlue,
                        color: CupertinoColors.black,
                        borderStrokeWidth: 3),
                    popupOptions: PopupOptions(
                        popupState: PopupState(),
                        popupSnap: PopupSnap.markerTop,
                        popupController: _popupController,
                        popupBuilder: (_, marker) {
                          var _poi = marker as PoiMarker;
                          return _poi.buildPopup(context, closePopup);
                        }),
                    builder: (context, markers) {
                      return Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: CupertinoColors.secondarySystemBackground),
                        child: markers.length
                            .toString()
                            .text
                            .size(12)
                            .center
                            .make(),
                      );
                    },
                  )),
                ],
              ),

              // Butons

              Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 45,
                      height: 40,
                      child: CupertinoButton(
                          child: Icon(CupertinoIcons.chevron_back),
                          onPressed: () {
                            context.navigator!.pop(false);
                          }),
                    ),
                    Container(
                      width: 45,
                      height: 40,
                      child: CupertinoButton(
                          child: Icon(_centerAlways
                              ? CupertinoIcons.location_circle_fill
                              : CupertinoIcons.location_circle),
                          onPressed: () {
                            getLocation();
                            setState(() {
                              _centerAlways = !_centerAlways;
                            });
                          }),
                    ),
                    Container(
                      width: 45,
                      height: 40,
                      child: CupertinoButton(
                          child: Icon(CupertinoIcons.arrow_left_right_square),
                          onPressed: () {
                            centerRoute(model);
                          }),
                    ),
                    Spacer(),
                    widget.options.search
                        ? CupertinoButton(
                            child: Icon(CupertinoIcons.search),
                            onPressed: () => intersect(),
                          )
                        : SizedBox.shrink(),
                    widget.options.weather
                        ? CupertinoButton(
                            child: Icon(Icons.beach_access),
                            onPressed: () => model.togglePlatges(),
                          )
                        : SizedBox.shrink(),
                    PullDownButton(
                      itemBuilder: (context) => model.mapTemplates
                          .asMap()
                          .entries
                          .map((entry) => PullDownMenuItem(
                                title: entry.value.nom,
                                onTap: () {
                                  print("${entry.key}, ${entry.value.nom}");
                                  return model.selectMap(entry.key);
                                },
                              ))
                          .toList(),
                      buttonBuilder: (context, showMenu) => CupertinoButton(
                        onPressed: showMenu,
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.map),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoColors.systemBackground
                                .withOpacity(0.7)),
                        width: 100,
                        height: 30,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 45,
                              height: 30,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Icon(
                                  Icons.backspace_outlined,
                                  size: 24,
                                ),
                                alignment: Alignment(0, 0),
                                onPressed: () => model.removeLastFromRoute(),
                              ),
                            ),
                            Container(
                              width: 45,
                              height: 30,
                              child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: Icon(
                                    CupertinoIcons.clear_circled,
                                    size: 24,
                                  ),
                                  alignment: Alignment(0, 0),
                                  onPressed: () => model.clearRoute()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),

            Container(
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: CupertinoColors.systemBackground
                .withOpacity(0.7)),
            width: 100,
            height: 30,
            alignment: Alignment.center,
            child: (((model.route.distance / 10.0).roundToDouble()/100.0).toString() + " km").text.center.make(),

            ),
                    Spacer(),
                    PlusMinusWidget(() {
                      var zoom = (mapController.zoom + 1).min(18.0);
                      var center = mapController.center;
                      myZoom = zoom;
                      mapController.move(center, zoom);
                    }, () {
                      var zoom = (mapController.zoom - 1).max(1.0);
                      var center = mapController.center;
                      myZoom = zoom;
                      mapController.move(center, zoom);
                    }),
                  ],
                ),
              ]),

              Container(
                width: context.screenWidth,
                height: context.screenHeight,
                alignment: Alignment.topCenter,
                child: Container(
                  width: 1,
                  height: context.screenHeight,
                  color: CupertinoColors.systemRed,
                ),
              ),

              Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.topCenter,
                width: context.screenWidth,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  isDesktop
                      ? CupertinoButton(
                          onPressed: () {
                            mapController.rotate(mapController.rotation + 1);
                            setState(() {
                              myHeading = mapController.rotation;
                            });
                          },
                          child: Icon(CupertinoIcons.minus),
                        )
                      : SizedBox.shrink(),
                  Container(
                    width: 105,
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color:
                            CupertinoColors.systemBackground.withOpacity(0.7)),
                    child:
                        (((360.0 - mapRotation()) % 360.0).floor().toString() ??
                                "")
                            .text
                            .color(CupertinoColors.systemRed)
                            .size(48)
                            .fontWeight(FontWeight.bold)
                            .center
                            .make(),
                  ),
                  isDesktop
                      ? CupertinoButton(
                          onPressed: () {
                            mapController.rotate(mapController.rotation - 1);
                            setState(() {
                              myHeading = mapController.rotation;
                            });
                          },
                          child: Icon(CupertinoIcons.plus),
                        )
                      : SizedBox.shrink(),
                ]),
              ),
            ];

            return Stack(children: stk);
          },
        ),
      ),
    );
  }
}

class MapPage extends Page {
  AppStateModel model;
  SQLDatabase db;

  MapPage(this.model, this.db) : super(key: ValueKey('MapPage'));

  @override
  Route createRoute(BuildContext context) {
    return CupertinoPageRoute(
        settings: this,
        builder: (BuildContext context) =>
            MapView(model, db, MapViewOptions(true, true)));
  }
}
