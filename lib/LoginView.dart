import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Utilities.dart';
import '/model/SQLDatabase.dart';
import 'package:velocity_x/velocity_x.dart';
import '/model/User.dart';
import '/model/Pla.dart';

import '/model/AppStateModel.dart';
import 'package:provider/provider.dart';

enum LoggedState {
  notLogged,
  error,
  ok
}

class LoginView extends StatefulWidget {

  final SQLDatabase db;


  const LoginView(this.db, {Key? key}) : super(key: key);

  @override
  _LoginViewState createState() {
    return _LoginViewState();
  }
}

class _LoginViewState extends State<LoginView> {

  LoggedState state = LoggedState.notLogged;
  String fullname = "";
  String name = "";
  String password = "";
  final _formKey = GlobalKey<FormState>();

  Widget buttonWidget(){
    switch(state){
      case LoggedState.notLogged :
        return "Login".text.color(Colors.white).size(18).fontWeight(FontWeight.bold).make();

      case LoggedState.error :
        return const Icon(CupertinoIcons.exclamationmark_octagon_fill, color: Colors.white,);

      case LoggedState.ok: {
        return const Icon(Icons.done, color: Colors.white);
      }
    }
  }

  double buttonSize() {
    switch (state) {
      case LoggedState.notLogged :
        return 150.0;

      case LoggedState.error :
        return 50.0;

      case LoggedState.ok:
        return 50.0;
    }
  }
  void gotoSignIn(BuildContext context, AppStateModel model) async {

    model.signIn();

  }

  Future<User?> getUser(SQLDatabase db, String user, String password) async{

    var answer = await db.search('users', {'username': name, 'password': password});
    if (answer.length == 1){
        fullname = answer[0]['nom'] + " " + answer[0]['cognoms'];
        return answer[0] as User;
    }else {
      fullname = "";
      return null;
    }
  }
  void login(BuildContext context, AppStateModel model) async {

    print("Login");
    if(_formKey.currentState!.validate()){

      var user = await getUser(widget.db, name, password);

      // Try go get the server
      setState(() {
        state  = user != null ? LoggedState.ok : LoggedState.error;
      });

      await Future.delayed(Duration(seconds: 1));

      if (user != null) {
        await model.loadPlans(widget.db, user);
        model.setUser(user);
      }
      else{
        setState(() {
          state = LoggedState.notLogged ;
        });

      }

    }

  }

  @override

  Widget build(BuildContext context){
  return Consumer<AppStateModel>(
  builder: (context, model, child){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        child: Column(children: [
          'kayak_icon'.image(200.0),
          "Benvingut $fullname".text.size(28).fontWeight(FontWeight.bold).make(),
          SizedBox(height: 20.0),
          Form(
            key: _formKey,
            child: CupertinoFormSection(
                //header: "Identifica't".text.make(),
                children: [
                  CupertinoFormRow(
                    prefix: "Nom".text.make(),
                    child: CupertinoTextFormFieldRow(
                      placeholder: "Entreu el nom d'usuari",
                      onChanged: (value){
                        name = value;
                        },
                       validator: (String? value) {
                        return null;
                      },
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: "Contrasenya".text.make(),
                    child: CupertinoTextFormFieldRow(
                      placeholder: "Entreu la contrasenya",
                      obscureText: true,
                      obscuringCharacter: '•',
                      onChanged: (value) {password = value;},
                      validator: (String? value) {
                        return null;
                      },
                    ),
                  ),
                ]),

          ),

          SizedBox(
            height: 40.0,
          ),
          Material(
            color: state == LoggedState.error ? CupertinoColors.destructiveRed :    context.cupertinoTheme.primaryColor,
            borderRadius:
            BorderRadius.circular( 50),
            child: InkWell(
              onTap: () => login(context, model),
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                width: buttonSize() ,
                height: 50,
                alignment: Alignment.center,
                child: buttonWidget(),
                ),
              ),
            ),


          CupertinoButton(
              child:  "Dona't d'alta".text.size(10).make(),
                  onPressed: () => gotoSignIn(context, model)),

        ]));
  });}
}

class LoginPage extends Page {
    final SQLDatabase db;

    LoginPage(this.db) : super(key: ValueKey('LoginPage'));

    @override
  Route createRoute(BuildContext context){
      return CupertinoPageRoute(settings: this, builder: (BuildContext context) => LoginView(db));
    }
}