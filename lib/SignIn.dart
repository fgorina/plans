import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '/model/User.dart';
import '/model/AppStateModel.dart';
import '/model/SQLDatabase.dart';
import 'package:provider/provider.dart';

class SignInView extends StatefulWidget {

  SQLDatabase db;
  SignInView(this.db, {Key? key}) : super(key: key);

  @override
  _SignInViewState createState() {
    return _SignInViewState();
  }
}

class _SignInViewState extends State<SignInView> {


  User user = User();
  String otherPassword = "";
  bool accept = false;

  void createUser(AppStateModel model) async {

    user['active'] = true;
    User  u = await widget.db.create(user) as User;
    model.setUser(u);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      body: SafeArea(
        child: Container(
          padding: Vx.m32,

          child: SingleChildScrollView(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "Inscriu-te".text.xl5.bold.color(context.theme.accentColor).make(),
              "Crea el teu usuari".text.xl2.make(),
              CupertinoFormSection(
                  header: "Les teves dades".text.make(),
                  children: [
                    CupertinoFormRow(
                      child: CupertinoTextFormFieldRow(
                        placeholder: "Entra el nom",
                        onChanged: (value) => user["nom"] = value,
                      ),
                      prefix: "Nom".text.make(),
                    ),
                    CupertinoFormRow(
                      child: CupertinoTextFormFieldRow(
                        placeholder: "Entra el/els cognoms",
                        onChanged: (value) => user["cognoms"] = value,

                      ),
                      prefix: "Cognoms".text.make(),
                    ),
                    CupertinoFormRow(
                      child: CupertinoTextFormFieldRow(
                        placeholder: "Entra el teu e-mail",
                        onChanged: (value) => user["email"] = value,
                      ),
                      prefix: "Email".text.make(),
                    ),
                    CupertinoFormRow(
                      child: CupertinoTextFormFieldRow(
                        placeholder: "Entra el teu telèfon",
                        onChanged: (value) => user["phone"] = value,
                      ),
                      prefix: "Telèfon".text.make(),
                    )


                  ]),

              CupertinoFormSection(
                  header: "El teu contacte proper".text.make(),
                  children: [
                    CupertinoFormRow(
                      child: CupertinoTextFormFieldRow(
                        placeholder: "Entra el nom",
                        onChanged: (value) => user["contacteProper"] = value,
                      ),
                      prefix: "Nom".text.make(),
                    ),
                    CupertinoFormRow(
                      child: CupertinoTextFormFieldRow(
                        placeholder: "parella, Amic, eetc.",
                        onChanged: (value) => user["relacioContacteProper"] = value,
                      ),
                      prefix: "Relació".text.make(),
                    ),
                    CupertinoFormRow(
                      child: CupertinoTextFormFieldRow(
                        placeholder: "Entra el seu e-mail",
                        onChanged: (value) => user["emailContacteProper"] = value,
                      ),
                      prefix: "Email".text.make(),
                    ),
                    CupertinoFormRow(
                      child: CupertinoTextFormFieldRow(
                        placeholder: "Entra el seu telèfon",
                        onChanged: (value) => user["telefonContacteProper"] = value,
                      ),
                      prefix: "Telèfon".text.make(),
                    )


                  ]),

              CupertinoFormSection(header: "User".text.make(), children: [
                CupertinoFormRow(
                  child: CupertinoTextFormFieldRow(
                    placeholder: "Entra el nom de usuari",
                    onChanged: (value) => user["username"] = value,
                  ),
                  prefix: "Usuari".text.make(),
                ),
                CupertinoFormRow(
                  child: CupertinoTextFormFieldRow(
                    obscureText: true,
                    onChanged: (value) => user["password"] = value,
                  ),
                  prefix: "Contrasenya".text.make(),
                ),
                CupertinoFormRow(
                  child: CupertinoTextFormFieldRow(
                    obscureText: true,
                    onChanged: (value) => otherPassword = value,
                  ),
                  prefix: "Confirma la Contrasenya".text.make(),
                )
              ]),
              CupertinoFormSection(
                  header: "Condicions".text.make(),
                  children: [
                    CupertinoFormRow(
                      child: CupertinoSwitch(
                        value: accept,
                        onChanged: (value) {setState(() {
                          accept = value;
                        });},
                      ),
                      prefix: "I Agree".text.make(),
                    ),
                  ]),
              20.heightBox,

            Consumer<AppStateModel>(
              builder: (context, model, child) {
                return Material(
                  color: context.cupertinoTheme.primaryColor,
                  borderRadius: BorderRadius.circular(50),
                  child: InkWell(
                    onTap: () => createUser(model),
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      width: 150,
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        "Inscriu-te",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ).centered();
              },
            ),

            ],
          ),
          ),
        ),
      ),
    );
  }
}

class SignInPage extends Page {
  final SQLDatabase db;

  SignInPage(this.db) : super(key: ValueKey('SignIn GorinaPage'));

  @override
  Route createRoute(BuildContext context){
    return CupertinoPageRoute(settings: this, builder: (BuildContext context) => SignInView(db));
  }
}