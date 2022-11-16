import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:plans/model/AppStateModel.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '/model/User.dart';
import '/model/SQLDatabase.dart';
import 'LoginView.dart';
import 'SignIn.dart';
import '/routes/MyAppRouterDelegate.dart';
import 'package:flutter/material.dart';

void main() {
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

    User user = User();
    db.registerTable(user);
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

class ActivityPlansHomePage extends StatefulWidget {

  SQLDatabase db;
  ActivityPlansHomePage(this.db, {Key? key}) : super(key: key);

  @override
  State<ActivityPlansHomePage> createState() => _ActivityPlansHomePageState();
}

class _ActivityPlansHomePageState extends State<ActivityPlansHomePage> {


  List<User> users = [];

  @override
  void initState() {
    super.initState();

  }

  void dispose() {
    super.dispose();
  }

  void update() async {
    var result = await widget.db.search('users', {'cognoms': 'Gorina'});
    if (result != null) {
      this.setState(() {
        users = result.map((e) => e as User).toList() as List<User>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text("Plans de Navegació"),
          ),
          backgroundColor: context.canvasColor,
          child: SafeArea(
            child: Consumer<AppStateModel>(
              builder: (context, model, child){
                return "Welcome ${model.userName}".text.make();
              }
            ),


          ));

  }
}

class HomePage extends Page {

  SQLDatabase db;

  HomePage(this.db) : super(key: ValueKey('HomePage'));

  @override
  Route createRoute(BuildContext context){
    return CupertinoPageRoute(settings: this, builder: (BuildContext context) => ActivityPlansHomePage(db));
  }
}