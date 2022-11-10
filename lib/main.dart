import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '/model/User.dart';
import '/model/SQLDatabase.dart';


void main() {
  runApp(ActivityPlansApp());
}

class ActivityPlansApp extends StatelessWidget {
  ActivityPlansApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return CupertinoApp(
      title: 'Plans',
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: ActivityPlansHomePage(),
    );
  }
}

class ActivityPlansHomePage extends StatefulWidget {
  ActivityPlansHomePage({Key? key}) : super(key: key);

  @override
  State<ActivityPlansHomePage> createState() => _ActivityPlansHomePageState();
}

class _ActivityPlansHomePageState extends State<ActivityPlansHomePage> {

  SQLDatabase db = SQLDatabase();
  User user =  User();
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    db.registerTable(user);
  }


  void dispose(){
    db.dispose();
  }
  void update() async {
    var result = await db.search('users', {'cognoms':'Gorina'});
    if (result != null ) {
        this.setState(() {
          users = result.map((e) => e as User).toList() as List<User>;
        });
      }
    }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Login"),
        ),
        child: SafeArea(
            child: Column(children: [
              Spacer(),
              Text("Primera linia"),
              CupertinoButton(child: Text("Pulsar"), onPressed: update),
              Container(
                height: 300,
                child: ListView(children: users.map((e) => Text(e['nom'] + ' ' + e['cognoms'])).toList()),
              ),
              Spacer(),
        ])));
  }
}
