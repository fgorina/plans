import 'package:flutter/foundation.dart' as foundation;
import 'package:plans/model/SQLDatabase.dart';
import 'package:velocity_x/velocity_x.dart';
import '/model/User.dart';
import '/model/Pla.dart';
import '/model/Itinerari.dart';

import '/Maps/MapSchema.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart'; // Suitable for most situations
import 'package:plans/Meteocat/POI.dart';

enum Screen {
  Login,
  SignIn,
  Profile,
  PlaList,
  Pla,
  ItinerariList,
  Itinerari,
  EmbarcacioList,
  Embarcacio
}

class AppStateModel extends foundation.ChangeNotifier {

  User? _currentUser;
  List<Pla> _plans = [];
  bool _isSigningIn = false;
  bool _mapShown = false;

  bool get isLogged => _currentUser != null;
  bool get isSigningIn => _isSigningIn;
  bool get isMapShown => _mapShown;

  void signIn(){
    if (!isLogged){
      _isSigningIn = true;
      notifyListeners();
    }
  }

  Screen _currentScreen = Screen.Login;

  Screen get currentScreen => _currentScreen;

  void setScreen(Screen screen){
    _currentScreen = screen;
    notifyListeners();
  }


   User? get user =>  _currentUser;
  String get userName => _currentUser != null ? _currentUser!['nom'] + ' ' + _currentUser!['cognoms'] : "";
  bool get isUserActive => _currentUser == null ? false : _currentUser!['active'];



  Future setUser(User user) async{
    _currentUser = user;
    _isSigningIn = false;
    notifyListeners();
  }

  void clearUser(){
    _currentUser = null;
    _isSigningIn = false;
    notifyListeners();
  }

  // Plans

  Pla? _currentPla;
  bool _editPla = false;
  bool _runPla = false;

  Pla? get pla => _currentPla;

  void setCurrentPla(Pla? pla){
    _currentPla = pla;
    _currentItinerari = null;
    notifyListeners();
  }
  void editPla(){
    if (_currentPla != null && !_runPla){
      _editPla = true;
    }
  }

  void runPla(){
    if(_currentPla != null && !_editPla){
      _runPla = true;
    }
  }

  Future loadPlans(SQLDatabase db, User u) async{
    var x = u['id'].toString();
    var l = await db.search('plans', {'usuari': x});
    _plans = l.map((e) => e as Pla).toList();
  }

  Future updatePla(SQLDatabase db, Pla pla) async {

    if(pla.isSaved()){
      await db.update(pla, pla['id']!);

    }else {
      _currentPla = await db.create(pla) as Pla?;
    }
   }

  List<Pla> get plans => _plans;

  // Embarcacions



  Future loadEmbarcacions(SQLDatabase db, User u) async{
   /*
    var x = u['id'].toString();
    var l = await db.search('plans', {'usuari': x});
    _plans = l.map((e) => e as Pla).toList();
    */

  }


  // Itineraris


  List<Itinerari> _itineraris = [];
  Itinerari? _currentItinerari;

  Future loadItineraris(SQLDatabase db, User u) async{
    var x = u['id'].toString();
    var l = await db.search('itineraris', {'creador': x});
    _itineraris = l.map((e) => e as Itinerari).toList();
  }

  void setCurrentItinerari(Itinerari itinerari){
    _currentItinerari = itinerari;
    _currentPla = null;
    notifyListeners();
  }
  Itinerari? get itinerari => _currentItinerari;
  List<Itinerari> get itineraris => _itineraris;

  // MAPS

  final List<MapSchema> mapTemplates = [
    MapSchema("Open Landscape","https://tile.thunderforest.com/landscape/{z}/{x}/{y}.jpg90?apikey=ab2214500d754861bbd9f8c785b6eb0d", "ab2214500d754861bbd9f8c785b6eb0d" , false, 'OPENLANDSCAPE', true),
    MapSchema("ICC Topo", "http://geoserveis.icc.cat/icc_mapesmultibase/noutm/wmts/topo/GRID3857/{z}/{x}/{y}.png", null, false, 'ICCTOPO', false),
    MapSchema("ICC Orto", "http://geoserveis.icc.cat/icc_mapesmultibase/noutm/wmts/orto/GRID3857/{z}/{x}/{y}.jpeg", null, false, 'ICCORTO', false),
    MapSchema("IGN France Topo", "http://wxs.ign.fr/choisirgeoportail/geoportail/wmts?SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&Layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX={z}&TILECOL={x}&TILEROW={y}&FORMAT=image%2Fpng", null, false, 'IGNTOPO', false),
    MapSchema("IGN France Orto", "http://wxs.ign.fr/choisirgeoportail/geoportail/wmts?SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&Layer=ORTHOIMAGERY.ORTHOPHOTOS&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX={z}&TILECOL={x}&TILEROW={y}&FORMAT=image%2Fjpeg", null, false, 'IGNORTO', false),
    MapSchema("Open Cycle","https://tile.thunderforest.com/cycle/{z}/{x}/{y}.jpg90?apikey=ab2214500d754861bbd9f8c785b6eb0d", "ab2214500d754861bbd9f8c785b6eb0d" , false, 'OPENCYCLE', false),
    MapSchema("Open Outdoors","https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.jpg90?apikey=ab2214500d754861bbd9f8c785b6eb0d", "ab2214500d754861bbd9f8c785b6eb0d" , false, 'OPENOUTDOORS', false),
    MapSchema("Open Sea", "http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png", null, true, 'OPENSEA', false),

  ];

  int _selectedMap = 0;  // Open Landscape com a seleccionat per defecte

  Future initCache() async {

    for(var schema in mapTemplates){
      var store = FMTC.instance(schema.cache);
      await  store.manage.createAsync();
    }
  }

  void showMap(){
    _mapShown = true;
    notifyListeners();
  }

  void hideMap(){
    _mapShown = false;
    notifyListeners();
  }

  void selectMap(int i){
    if (i >= 0 && i < mapTemplates.length){
      if (mapTemplates[i].transparent) {
        mapTemplates[i].shown.toggle();
      }else {
        _selectedMap = i;
        print("Selecting " + mapTemplates[_selectedMap].nom);
      }
      notifyListeners();
    }
  }

  MapSchema  get currentMap => mapTemplates[_selectedMap];
  List<MapSchema> get shownMaps => mapTemplates.where((element) => element.shown).toList();
  MapSchema get openSeaMap => mapTemplates[7];

  // Weather

  POI aPoi = POI('');   // Just to maintain platges online
  bool _showPlatges = true;

  bool get showPlatges => _showPlatges;

  void togglePlatges(){
    _showPlatges = !_showPlatges;
    notifyListeners();
    print("Changed to $_showPlatges");
  }
  // Route edition

  Path<LatLng> _route = Path<LatLng>.from([]);

  void addToRoute(LatLng point){
    _route.add(point);
    notifyListeners();
  }

  void removeLastFromRoute(){
    List<LatLng> rest = _route.coordinates.sublist(0, _route.nrOfCoordinates-1);
    _route = Path.from(rest);
    notifyListeners();
  }

  void clearRoute(){
    _route.clear();
    notifyListeners();
  }

  void setRoute(Path path){
    _route = path;
    notifyListeners();
  }

  Path<LatLng> get route => _route;

}
