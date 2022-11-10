import '/model/RowProtocol.dart';

class User extends Row{

    @override static  String _tableName = 'users';
    @override static  List<String> _fields = ['id',
        'nom',
        'cognoms',
        'email',
        'phone',
        'active',
        'contacteProper',
        'telefonContacteProper',
        'emailContacteProper',
        'relacioContacteProper',
        'username',
    ];

   @override String get tableName => User._tableName;
   @override List<String> get fields => User._fields;


    User();

    User.fromMap(Map<String, dynamic> map){
        update(map);
    }

    User.fromJSON(String json){
        updateFromJSON(json);
    }

    User newRow(){
        return User();
    }
    @override
    String toString() => this['nom'] ?? "" ;
}

