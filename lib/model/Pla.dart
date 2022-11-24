import '/model/RowProtocol.dart';

class Pla extends Row{

  @override static  String _tableName = 'plans';
  @override static  List<String> _fields = ['id',
    'nom',
    'descripcio',
    'usuari',
    'dateCreated',
    'nParticipants',
    'nEmbarcacions',
    'puntSortida',
    'puntAparcament',
    'infoVehicles',
    'puntArribada',
    'sortidaPrevista',
    'arribadaPrevistaDe',
    'arribadaPrevistaFins',
    'accionsNo',
    'compartirEmail1',
    'compartirEmail2',
    'compartirEmail3',
    'actiu',
    'estat',
    'activitat',
  ];

  @override String get tableName => Pla._tableName;
  @override List<String> get fields => Pla._fields;


  Pla();

  Pla.fromMap(Map<String, dynamic> map){
    update(map);
  }

  Pla.fromJSON(String json){
    updateFromJSON(json);
  }

  Pla newRow(){
    return Pla();
  }

}

