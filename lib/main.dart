import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:plans/model/AppStateModel.dart';
import 'package:provider/provider.dart';
import '/model/User.dart';
import '/model/Pla.dart';
import '/model/Itinerari.dart';

import '/model/SQLDatabase.dart';
import '/routes/MyAppRouterDelegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
 // Suitable for most situations

import 'HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterMapTileCaching.initialise(await RootDirectory.normalCache);
  runApp(ActivityPlansApp());
}

class ActivityPlansApp extends StatefulWidget {
  ActivityPlansApp({Key? key}) : super(key: key);

  _ActivityPlansAppState createState() => _ActivityPlansAppState();
}

class _ActivityPlansAppState extends State<ActivityPlansApp>{

  SQLDatabase db = SQLDatabase();
  AppStateModel model = AppStateModel();
  late  MyAppRouterDelegate delegate ;
  @override

  void initState() {

    model.initCache();
    User user = User();
    db.registerTable(user);
    Pla pla = Pla();
    db.registerTable(pla);
    Itinerari itinerari = Itinerari();
    db.registerTable(itinerari);
    delegate = MyAppRouterDelegate(model, db);



    super.initState();
  }

  void dispose() {
    db.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return  ChangeNotifierProvider<AppStateModel>(
        create: (_) => model,
        child:  Consumer<AppStateModel>(

        builder : (context, model, child) {
          return CupertinoApp(
              title: 'Plans',
              theme: const CupertinoThemeData(brightness: Brightness.light),
              home: Router(routerDelegate: delegate)
          )
          ;
        }

    ),
    );
  }
}
