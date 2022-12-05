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

  String? stringValueOf(String field){
    var v = _values[field];

    if (v == null){ return null; }

    return v.toString();
  }

  int? intValueOf(String field){
    var v = _values[field];
    if (v == null) {return null;}

    if (v.runtimeType == int){
      return v as int;
    }
    else if (v.runtimeType == String){
        return int.tryParse(v) as int?;
        return int.tryParse(v) as int?;
    } else if (v is num){
      return (v as num).toInt();
    } else {
      return null;
    }
  }

  double? doubleValueOf(String field){
    var v = _values[field];
    if (v == null) {return null;}

    if (v.runtimeType == double){
      return v as double;
    }
    else if (v.runtimeType == String){
      return double.tryParse(v) as double?;
    } else if (v is num){
      return (v as num).toDouble();
    } else {
      return null;
    }
  }



  DateTime? dateValueOf(String field){
    var v = _values[field];
    if (v == null) {return null;}

    if (v.runtimeType == DateTime){
      return v as DateTime;
    } else if (v.runtimeType == String){ // Should be ann ISO String
      return DateTime.tryParse(v) as DateTime?;
    } else if (v is num){
      return DateTime.fromMillisecondsSinceEpoch(v.toInt()) as DateTime?;
    } else {
      return null;
    }

  }


  String toJSON() => json.encode(_values);

  Row newRow();

  Row newRowFromMap(Map<String, dynamic> map){
    var nova = newRow();
    nova.update(map);
    return nova;

  }

  Row copy(){
    return newRowFromMap(this._values);
  }

  String toString(){
    var fields = this.fields;

    return fields.map((e) => e + " : " + this[e].toString()).join(", ");

  }

  bool isSaved(){
    return this['id'] != null;
  }


}