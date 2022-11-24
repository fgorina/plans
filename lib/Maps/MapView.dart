import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:intl/intl.dart';

import 'package:latlong2/latlong.dart';
import '/model/AppStateModel.dart';

import 'package:flutter/services.dart';
import 'package:plans/model/AppStateModel.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:location/location.dart';
import '/Maps/MapSchema.dart';
import '/Meteocat/POI.dart';

class PoiMarker extends Marker {
  POI poi = POI("");

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
    // Get date and time

    DateFormat df = DateFormat("dd/MM HH:mm");

    var now = DateTime.now();
    WeatherCondition weather = poi.weatherNearestTo(now)!;
    String ds = df.format(weather.data!);

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: CupertinoColors.white),
      width: 250,
      height: 200,
      padding: EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => close(this),
        child: SingleChildScrollView(
          child: Column(
            children: poi.weatherFrom(now).map((e) {
              return Row(children: [
                Container(
                    width: 80,
                    child: df.format(e.data!).text.size(12).start.make()),
                Container(
                    width: 60,
                    child: (((e.velocitatVent!) * 3.6).toStringAsFixed(0) +
                            " km/h")
                        .text
                        .size(12)
                        .end
                        .make()),
                Container(
                    width: 60,
                    child: (e.alturaOna!.toStringAsFixed(2) + " m")
                        .toString()
                        .text
                        .size(12)
                        .end
                        .make()),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class MapView extends StatefulWidget {
  AppStateModel model;

  MapView(this.model);

  @override
  _MapViewState createState() {
    return _MapViewState();
  }
}

class _MapViewState extends State<MapView> {
  LatLng? myLocation = null;
  double myZoom = 13.0;

  final mapController = MapController();
  bool _showMapPicker = false;

  List<Marker> _markers = [];
  PopupController _popupController = PopupController();

  _MapViewState();

  void closePopup(Marker mk) {
    _popupController..hidePopupsOnlyFor([mk]);
  }

  void loadPlatja() async {
    await POI.loadPlatges();

    // Add far away to the map
    _markers = [];
    POI.marEndins.forEach((element) {
      _markers.add(PoiMarker(
        element,
        point: element.info!.coordenades,
        builder: (context) => Icon(
          CupertinoIcons.circle,
          color: CupertinoColors.systemRed,
        ),
      ));
    });

    var platja = POI("llanca-de-grifeu");
    await platja.load();

    setState(() {});
  }

  void getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    myLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    myZoom = mapController.zoom;
    mapController.move(myLocation!, myZoom);
  }

  void toggleMapPicker() async {
    setState(() {
      _showMapPicker = !_showMapPicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _selectedItem = 0;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Map"),
        trailing: CupertinoButton(
          onPressed: loadPlatja,
          child: Icon(CupertinoIcons.plus),
        ),
      ),
      backgroundColor: context.canvasColor,
      child: SafeArea(
        child: Consumer<AppStateModel>(
          builder: (context, model, child) {
            var stk = [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: LatLng(51.5, -0.09),
                  zoom: 8.0,
                  onTap: (pos, latlon) {
                    print(latlon);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: model.currentMap.schema,
                    // additionalOptions: {
                    //   "apikey": "ab2214500d754861bbd9f8c785b6eb0d",
                    //},
                    userAgentPackageName: 'es.gorina.plans',
                  ),
                  //MarkerLayer(markers: markers),
                  MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                    markers: _markers,
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
                      return Text(markers.length.toString());
                    },
                  )),
                ],
              ),

              //
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                      child: Icon(CupertinoIcons.location_circle),
                      onPressed: getLocation),
                  Spacer(),
                  CupertinoButton(
                      child: Icon(CupertinoIcons.globe),
                      onPressed: toggleMapPicker),
                ],
              ),
            ];

            if (_showMapPicker) {
              var mp =
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Spacer(),
                Container(
                  height: 250.0,
                  color: CupertinoColors.white,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 180.0,
                          child: CupertinoPicker(
                            magnification: 1.22,
                            squeeze: 1.2,
                            useMagnifier: true,
                            itemExtent: 32.0,
                            backgroundColor: CupertinoColors.white,
                            // This is called when selected item is changed.
                            onSelectedItemChanged: (int selectedItem) {
                              _selectedItem = selectedItem;
                            },
                            children: model.mapTemplates
                                .map((e) => e.nom.text.make())
                                .toList(),
                          ),
                        ),
                        CupertinoButton(
                            child: "Seleccionar".text.make(),
                            onPressed: () {
                              setState(() {
                                model.selectMap(_selectedItem);
                                _showMapPicker = false;
                              });
                            }),
                      ]),
                ),
              ]);

              stk.add(mp);
            }
            return Stack(children: stk);
          },
        ),
      ),
    );
  }
}

class MapPage extends Page {
  AppStateModel model;

  MapPage(this.model) : super(key: ValueKey('MapPage'));

  @override
  Route createRoute(BuildContext context) {
    return CupertinoPageRoute(
        settings: this, builder: (BuildContext context) => MapView(model));
  }
}
