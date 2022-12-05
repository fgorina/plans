import '/model/RowProtocol.dart';
import '/WKT_Decoder.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import '/model/PathExtension.dart';


class Itinerari extends Row{

  @override static  String _tableName = 'itineraris';
  @override static  List<String> _fields = ['id',
    'nom',
    'descripcio',
    'creador',
    'geo',
  ];

  @override String get tableName => Itinerari._tableName;
  @override List<String> get fields => Itinerari._fields;
  List<LatLng>? get coords => (this['geo'] as Path<LatLng>?)?.coordinates;

  Path<LatLng> get path => (this['geo'] as Path<LatLng>?) ?? Path<LatLng>.from([]);



  Itinerari();

  Itinerari.fromMap(Map<String, dynamic> map){
    update(map);
    String geoString = this['geo'] as String;
    var something = WKTDecoder().decode(geoString);
    this['geo'] = something.asLineString();

  }

  Itinerari.fromJSON(String json){
    updateFromJSON(json);
  }

  Itinerari newRow(){
    return Itinerari();
  }

  void update (Map<String, dynamic> map){
    super.update(map);
    String geoString = this['geo'] as String;
    var something = WKTDecoder().decode(geoString);
    this['geo'] = something.asLineString();

  }

  String toJSON() {

      var f = this.fields;
      Map<String, dynamic> values = {};

      for (var field in this.fields) {
        values[field] = this[field];
      }
    values['geo'] = path!.wkt;
    return json.encode(values);
  }
}

