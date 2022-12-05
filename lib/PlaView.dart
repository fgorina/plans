import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '/model/User.dart';
import '/model/Pla.dart';
import '/model/AppStateModel.dart';
import '/model/SQLDatabase.dart';
import 'package:provider/provider.dart';
import '/Maps/MapView.dart';

class PlaView extends StatefulWidget {

  SQLDatabase db;
  Pla _pla;
  AppStateModel model;

  PlaView(this.db, this._pla, this.model, {Key? key}) : super(key: key);

  @override
  _PlaViewState createState() {
    return _PlaViewState(_pla, model);
  }
}

class _PlaViewState extends State<PlaView> {


  Pla _pla;
  AppStateModel _model;
  TextEditingController _descripcioController = TextEditingController( );
  TextEditingController _sortidaController = TextEditingController( );
  TextEditingController _arribadaController = TextEditingController( );


  _PlaViewState(this._pla, this._model);

  void initState(){
    super.initState();
    _descripcioController.text = _pla["descripcio"].toString();
    _sortidaController.text = _pla["puntSortida"].toString();
    _arribadaController.text = _pla["puntArribada"].toString();
  }

   void doPlaOp() async{

    var _newPla = _pla.copy();

    // Això es una chapuza mentre decidim com guardart l'itinerari
    _newPla['descripcio'] = _newPla['descripcio'].toString();
    _newPla['puntSortida'] = _newPla['puntSortida'].toString();
    _newPla['puntArribada'] = _newPla['puntArribada'].toString();

    if (_pla.isSaved()){
      // Modify values of pla
      await widget.db.update(_newPla, _newPla['id']!);
    }else {
      await widget.db.create(_newPla);
    }

  }

  Future openMap(BuildContext context) async {

    var options = MapViewOptions(false, false);
    var route = CupertinoPageRoute(builder: (context) => MapView(_model, widget.db, options), title: "Map View", );
    await Navigator.push(context, route);

    setState(() {

      if (_model.route.nrOfCoordinates > 0) {
        _pla["descripcio"] = _model.route;
        _pla["puntSortida"] = _model.route.first;
        _pla["puntArribada"] = _model.route.last;
      }else {
        _pla["descripcio"] = [];
        _pla["puntSortida"] = null;
        _pla["puntArribada"] = null;
      }
      _descripcioController.text = _pla["descripcio"].toString();
      _sortidaController.text = _pla["puntSortida"].toString();
      _arribadaController.text = _pla["puntArribada"].toString();
      print(_pla["descripcio"] );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.canvasColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(_pla['nom'] ?? 'Nou Plà'),
        trailing:
       CupertinoButton(
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
                            onChanged: (value) => setState((){_pla["nom"] = value;}),
                          ),
                        prefix: "Nom".text.make(),
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
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ["Itinerari".text.make(),

                      Container(
                        padding: EdgeInsets.zero,
                        height: 40,
                      child: CupertinoButton(child: Icon(CupertinoIcons.globe),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                        await openMap(context);
                      }, ),
                      ),


                    ]),





                    children: [
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          controller: _sortidaController,
                          placeholder: "Punt de Sortida",
                          onChanged: (value) => _pla["puntSortida"] = value,
                        ),
                        prefix: "Punt Sortida".text.make(),
                      ),
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          controller: _arribadaController,
                          placeholder: "Punt Arribada",
                          onChanged: (value) => _pla["puntArribada"] = value,
                        ),
                        prefix: "Punt Arribada".text.make(),
                      ),
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          controller: _descripcioController,
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