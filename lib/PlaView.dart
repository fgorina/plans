import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '/model/User.dart';
import '/model/Pla.dart';
import '/model/AppStateModel.dart';
import '/model/SQLDatabase.dart';
import 'package:provider/provider.dart';

class PlaView extends StatefulWidget {

  SQLDatabase db;
  Pla _pla;
  AppStateModel model;

  PlaView(this.db, this._pla, this.model, {Key? key}) : super(key: key);

  @override
  _PlaViewState createState() {
    return _PlaViewState(_pla);
  }
}

class _PlaViewState extends State<PlaView> {


  Pla _pla;

  _PlaViewState(this._pla);

  void doPlaOp(){

  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.canvasColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(_pla['nom'] ?? 'Nou Plà'),
        trailing: CupertinoButton(
          onPressed: () => widget.model.editPla,
          child: Icon(CupertinoIcons.pencil),
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: Vx.m32,

          child: SingleChildScrollView(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //"Pla".text.xl5.bold.color(context.theme.accentColor).make(),
                !_pla.isSaved() ? "Crea el teu plà".text.xl2.make() : "Modifica plà".text.xl2.make(),
                CupertinoFormSection(
                    header: "Dades Generals".text.make(),
                    children: [
                      CupertinoFormRow(
                          child: CupertinoTextFormFieldRow(
                            initialValue: _pla["nom"]  ?? "",
                            placeholder: "Nom del plà",
                            onChanged: (value) => _pla["nom"] = value,
                          ),
                        prefix: "Data creat".text.make(),
                      ),
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          initialValue: _pla.stringValueOf('nParticipants') ,
                          placeholder: "Participants",
                          onChanged: (value) => _pla["nParticipants"] = value,
                        ),
                        prefix: "Nombre participants".text.make(),
                      ),
                    CupertinoFormRow(
                      child: CupertinoTextFormFieldRow(
                        initialValue: _pla.stringValueOf('nEmbarcacions') as String?,
                        placeholder: "Embarcacions",
                        onChanged: (value) => _pla["nEmbarcacions"] = value,
                      ),
                      prefix: "Nombre embarcacions".text.make(),
                    ),

                    ]),
                20.heightBox,
                CupertinoFormSection(
                    header: "Itinerari".text.make(),
                    children: [
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          initialValue: _pla["puntSortida"]  ?? "",
                          placeholder: "Punt de Sortida",
                          onChanged: (value) => _pla["puntSortida"] = value,
                        ),
                        prefix: "Punt Sortida".text.make(),
                      ),
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          initialValue: _pla["puntArribada"]  ?? "",
                          placeholder: "Punt Arribada",
                          onChanged: (value) => _pla["puntArribada"] = value,
                        ),
                        prefix: "Punt Arribada".text.make(),
                      ),
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          initialValue: _pla.stringValueOf('descripcio') as String?,
                          placeholder: "Descripció itinerari",
                          onChanged: (value) => _pla["descripcio"] = value,
                          style: TextStyle(fontSize: 12,),
                          expands: true,
                          minLines: null,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,

                        ),
                        prefix: "Itinerari".text.make(),

                      ),
                    ]),


                20.heightBox,
                CupertinoFormSection(
                    header: "Aparcament".text.make(),
                    children: [
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          initialValue: _pla["puntAparcament"]  ?? "",
                          placeholder: "Lloc a on deixem els vehicles",
                          onChanged: (value) => _pla["puntSortida"] = value,
                        ),
                        prefix: "Aparcament".text.make(),
                      ),
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          initialValue: _pla["infoVehicles"]  ?? "",
                          placeholder: "Descripció dels vehicles",
                          onChanged: (value) => _pla["infoVehicles"] = value,
                          expands: true,
                          minLines: null,
                          maxLines: null,

                        ),
                        prefix: "Detall Vehicles".text.make(),
                      ),

                    ]),







                20.heightBox,

                Consumer<AppStateModel>(
                  builder: (context, model, child) {
                    return Material(
                      color: context.cupertinoTheme.primaryColor,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        onTap: doPlaOp,
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          width: 150,
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            !_pla.isSaved() ? "Crea" : "Modifica",
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

class PlaViewPage extends Page {
  final SQLDatabase db;
  final Pla pla;
  final AppStateModel model;

  PlaViewPage(this.db, this.pla, this.model) : super(key: ValueKey('Pla Page'));

  @override
  Route createRoute(BuildContext context){
    return CupertinoPageRoute(settings: this, builder: (BuildContext context) => PlaView(db, pla, model));
  }
}