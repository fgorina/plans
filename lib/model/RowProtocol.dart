import 'dart:convert';


abstract class Row {

  static String _tableName = '';
  static List<String> _fields = [];

  Map<String, dynamic> _values = {};

  String get tableName => Row._tableName;
  List<String> get fields => Row._fields;

  void update (Map<String, dynamic> map){
    var f = this.fields;
    for (var field in this.fields) {
      _values[field] = map[field];
    }
  }

  void updateFromJSON(String value){
    var map = json.decode(value);
    this.update(map);
  }

  operator [](String f) => _values[f];

  operator []=(String f, dynamic value) => _values[f] = value;

  String toJSON() => json.encode(_values);

  Row newRow();

  Row newRowFromMap(Map<String, dynamic> map){
    var nova = newRow();
    nova.update(map);
    return nova;

  }


}