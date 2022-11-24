import 'package:flutter/foundation.dart' as foundation;
import 'package:plans/model/SQLDatabase.dart';
import '/model/User.dart';
import '/model/Pla.dart';
import '/Maps/MapSchema.dart';

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

  void setCurrentPla(Pla pla){
    _currentPla = pla;
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

  // MAPS

  final List<MapSchema> mapTemplates = [
    MapSchema("Open Landscape","https://tile.thunderforest.com/landscape/{z}/{x}/{y}.jpg90?apikey=ab2214500d754861bbd9f8c785b6eb0d", "ab2214500d754861bbd9f8c785b6eb0d" , false),
    MapSchema("ICC Topo", "http://geoserveis.icc.cat/icc_mapesmultibase/noutm/wmts/topo/GRID3857/{z}/{x}/{y}.png", null, false),
    MapSchema("ICC Orto", "http://geoserveis.icc.cat/icc_mapesmultibase/noutm/wmts/orto/GRID3857/{z}/{x}/{y}.jpeg", null, false),
    MapSchema("IGN France Topo", "http://wxs.ign.fr/choisirgeoportail/geoportail/wmts?SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&Layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX={z}&TILECOL={x}&TILEROW={y}&FORMAT=image%2Fpng", null, false),
    MapSchema("IGN France Orto", "http://wxs.ign.fr/choisirgeoportail/geoportail/wmts?SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetTile&Layer=ORTHOIMAGERY.ORTHOPHOTOS&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX={z}&TILECOL={x}&TILEROW={y}&FORMAT=image%2Fjpeg", null, false),
    MapSchema("Open Cycle","https://tile.thunderforest.com/cycle/{z}/{x}/{y}.jpg90?apikey=ab2214500d754861bbd9f8c785b6eb0d", "ab2214500d754861bbd9f8c785b6eb0d" , false),
    MapSchema("Open Outdoors","https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.jpg90?apikey=ab2214500d754861bbd9f8c785b6eb0d", "ab2214500d754861bbd9f8c785b6eb0d" , false),
    MapSchema("Open Sea", "http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png", null, true),

  ];

  int _selectedMap = 0;  // Open Landscape com a seleccionat per defecte

  void showMap(){
    _mapShown = true;
    notifyListeners();
  }

  void hideMap(){
    _mapShown = false;
    notifyListeners();
  }

  void selectMap(int i){
    if (i > 0 && i < mapTemplates.length){
      _selectedMap = i;
      print("Selecting " + mapTemplates[_selectedMap].nom);
      notifyListeners();
    }
  }

  MapSchema  get currentMap => mapTemplates[_selectedMap];

}