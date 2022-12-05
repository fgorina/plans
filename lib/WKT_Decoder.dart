import 'package:latlong2/latlong.dart';


class WKTElement {
  String name;
  List<dynamic> parameters;

  WKTElement(this.name, this.parameters);

  LatLng? asPoint(){
    if(name == "POINT"){
      return parameters[0] as LatLng;
    }else{
      return null;
    }
  }

  Path<LatLng>? asLineString(){
    if (name == "LINESTRING"){
      return Path.from(parameters.cast<LatLng>());
    }else{
      return null;
    }
  }



  String toString(){
    var s = "Element $name{";
    for(var t in parameters){
      s = "$s ${t.toString()}, ";
    }
    s = "$s }\n";
    return s;
  }
}


class WKTDecoder{

  WKTDecoder();

   final List<String> _names = [
    'POINT',
    'LINESTRING',
    'POLYGON',
    'MULTIPOINT',
    'MULTILINESTRING',
    'MULTIPOLYGON',
    'GEOMETRYCOLLECTION',
  ];

    bool _isNumeric(dynamic t) {


    if(t == null) {
      return false;
    }
    if(t.runtimeType == String){
      var s = t as String;
      return double.tryParse(s) != null;
    } else {
      return false;
    }
  }

    bool _isName(dynamic t){

    if(t.runtimeType == String){
      var s = t as String;
      return _names.contains(s);
    } else {
      return false;
    }
  }

    bool _isStart(dynamic t){
    if(t.runtimeType == String){
      var s = t as String;
      return s == "(";
    } else{
      return false;
    }

  }

    bool _isEnd(dynamic t){
    if(t.runtimeType == String){
      var s = t as String;
      return s == ")";
    } else{
      return false;
    }

  }

    bool _isComma(dynamic t){
    if(t.runtimeType == String){
      var s = t as String;
      return s == ",";
    } else{
      return false;
    }

  }

    List<String> tokenize(String s){

    List<String> output = [];

    var token = "";

    for(var ic in s.runes){

      var c = String.fromCharCode(ic);
      if (c == "(" || c == ")" || c == ","){
        if (token.isNotEmpty){
          output.add(token);
          token = "";
        }
        output.add(c);

      } else if (c == " " ){
        if( token.isNotEmpty){
          output.add(token);
          token = "";
        }
      }else{
        token += c;
      }

    }
    if (token.isNotEmpty){
      output.add(token);

    }

    return output;
  }

  WKTElement decode(String str){


    List<String> source = tokenize(str);
    List<dynamic> params = [];

    for(var token in source){

      if (_isName(token)){
        params.add(token);
      }
      else if (_isStart(token) || _isNumeric(token)){
        params.add(token);
      }
      else if (_isComma(token)){
        List<String> data = [];

        while(_isNumeric(params.last)){
          data.insert(0, params.removeLast());
        }
        if (data.length > 0){
          //var ele = WKTElement("COORD", data);
          var ele = LatLng(double.parse(data[1]), double.parse(data[0]));
          params.add(ele);
        }

      }

      else if (_isEnd(token)){
        List<dynamic> data = [];
        while(_isNumeric(params.last)){
          data.insert(0, params.removeLast());
        }

        if (data.length > 0){
          //var ele = WKTElement("COORD", data);
          var ele = LatLng(double.parse(data[1]), double.parse(data[0]));
          params.add(ele);
        }

        data = [];

        while(!_isStart(params.last)){
          data.insert(0, params.removeLast());
        }
        params.removeLast();




        if (_isName(params.last)){
          var op = WKTElement(params.last, data);
          params.removeLast();
          params.add(op);
        } else {
          params.add(data);
        }

      }
    }
    return params.last as WKTElement;
  }
}

