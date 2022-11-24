import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:velocity_x/velocity_x.dart';


class WeatherCondition{
  DateTime? data;
  double? temperatura;
  double? humitatRelativa;
  double? velocitatVent;
  double? direccioVent;
  int? estatCel;   // Canviar a enum
  double? alturaOna;
  double? direccioOna;
  double? temperaturaAigua;
  double? uviMaxim;
  double? uviPrevist;

  WeatherCondition(Map<String, dynamic> dades){

    data = DateTime.tryParse(dades['data'] ?? 'x');

    var values = dades['variables'];  // Això es una llista

    for(Map<String, dynamic> val in values){ // value es un Map
      String nom = val['nom'] as String;
      double valor = val['valor'] as double;

      switch(nom){
        case 'temperatura':
          this.temperatura = valor;
          break;

        case 'humitat_relativa':
          this.humitatRelativa = valor;
          break;

        case 'velocitat_vent':
          this.velocitatVent = valor;
          break;

        case 'direccio_vent':
          this.direccioVent = valor;
          break;
        case 'estat_cel':
          this.estatCel = valor.toInt();
          break;
        case 'altura_ona':
          this.alturaOna = valor;
          break;
        case 'direccio_ona':
          this.direccioOna = valor;
          break;
        case 'temperatura_aigua':
          this.temperaturaAigua = valor;
          break;
        case 'uvi_maxim':
          this.uviMaxim = valor;
          break;
        case 'uvi_previst':
          this.uviPrevist = valor;
          break;

      }

    }
  }

  String toString(){

    return "Data : $data T : $temperatura Vent: $velocitatVent Ones: $alturaOna";
  }
}

class POIInfo{

  String municipi = "";
  String nom= "";
  LatLng coordenades = LatLng(0.0, 0.0);
  String slug= "";


  POIInfo(Map<String, dynamic> dades){
    municipi = dades['municipi'] ?? "";
    nom = dades['nom'] ?? "";
    Map<String, dynamic> cd = ( dades['coordenades'] ?? {}) as Map<String, dynamic>;
    coordenades = LatLng(cd['latitud'] ?? 0.0, cd['longitud'] ?? 0.0);
    slug = dades['slug'] ?? "";
  }

  String toString() => "POI $nom a $municipi";
}

class POI {

  static List<POIInfo> platges = [];
  static List<POI> marEndins = [];

  static String schema = "https";
  static String host = "www.meteo.cat";
  static String base = "prediccio/platges/";
  String slug = "llanca-de-grifeu";
  static String name = "Platja de Grifeu - Llançà";

  POIInfo? info;
  Map<String, dynamic> metadades = {};
  List<WeatherCondition> dades = [];

  POI(this.slug);

  static Future loadPlatges() async{

    var url =  Uri(scheme: schema,host: host, path : base);

    var response = await http.get(url);
    var body = response.body;

    var document = parse(body);
    var elements = document.getElementsByTagName("script");

    for(var element in elements) {
      if (element.nodes.length > 0) {
        var local = element.nodes[0];
        if ((local.text ?? "").contains('Meteocat.mapaPlatges')) {
          LineSplitter ls = LineSplitter();
          var lines = ls.convert(local.text ?? "");

          List<dynamic>  unformatedDades = [];
          for (var line in lines){
            if(line.contains("metadadesPuntsPlatges:")) {
              var clean = line.substring(
                  line.indexOf('['), line.lastIndexOf(']') + 1);
              unformatedDades = json.decode(clean);

              for (var dada in unformatedDades) {
                POI.platges.add(POIInfo(dada));
              }

              print(POI.platges);
            }

            if(line.contains("prediccioIMetadadesPuntsMarEndins:")){

              var clean = line.substring(
                  line.indexOf('['), line.lastIndexOf(']') + 1);
              unformatedDades = json.decode(clean);

              for (var dada in unformatedDades) {

                var metadata = dada['metadades'];
                var prediccions = dada['prediccions'];

                var info = POIInfo(metadata);
                List<dynamic> weather = (prediccions.map((e) => WeatherCondition(e) as WeatherCondition).toList());

                // Crearem una platja amb l'informacio

                var punt = POI(info.slug);
                punt.info = info;
                punt.dades = [];
                weather.forEach((element) {
                  punt.dades.add(element);
                });

                marEndins.add(punt);
              }
            }
          }
        }
      }
    }
  }


  Future load() async{

    var url =  Uri(scheme: POI.schema,host: POI.host, path : POI.base + slug);
    
    var response = await http.get(url);
    var body = response.body;

    var document = parse(body);
    var elements = document.getElementsByTagName("script");

    for(var element in elements){
      if (element.nodes.length > 0) {
        var local = element.nodes[0];
        if ((local.text ?? "").contains('drawPlatja')) {
          LineSplitter ls = LineSplitter();
          var lines = ls.convert(local.text ?? "");

          List<dynamic>  unformatedDades = [];
          for (var line in lines){
            if(line.contains("metadades:")){

              var clean = line.substring(line.indexOf('{'), line.lastIndexOf('}')+1);
              metadades = json.decode(clean);
              info = POIInfo(metadades);

            } else if (line.contains("dades:")){
              var clean  = line.substring(line.indexOf('['), line.lastIndexOf(']')+1);
              unformatedDades = json.decode(clean);

              for(var dada in unformatedDades){
                dades.add(WeatherCondition(dada));
              }
            }
           }
        }
      }
    }
  }


  WeatherCondition? weatherNearestTo(DateTime t){

    if (dades.length == 0){
      return  null;
    }

    var selected = dades[0];
    var d = (selected.data!.difference(t).inSeconds).abs();

    for (var w in dades ){
      int s = (w.data!.difference(t).inSeconds).abs();
      if (s < d ){
        selected = w;
        d = s;
      }
    }

    print(t);
    print(selected.data);
    return selected;
  }

  List<WeatherCondition> weatherFrom(DateTime t){

    return dades.where((element) => element.data!.isAfter(t)).toList();
  }

}


