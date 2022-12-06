import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '/model/User.dart';
import '/model/Itinerari.dart';
import '/model/AppStateModel.dart';
import '/model/SQLDatabase.dart';
import 'package:provider/provider.dart';
import '/Maps/MapView.dart';
import 'package:latlong2/latlong.dart';
import '/model/PathExtension.dart';
import 'package:geocoding/geocoding.dart';

class ItinerariView extends StatefulWidget {

  SQLDatabase db;
  Itinerari _itinerari;
  AppStateModel model;

  ItinerariView(this.db, this._itinerari, this.model, {Key? key}) : super(key: key);

  @override
  _ItinerariViewState createState() {
    return _ItinerariViewState(_itinerari, model);
  }
}

class _ItinerariViewState extends State<ItinerariView> {


  Itinerari _itinerari;
  AppStateModel _model;

  TextEditingController _descripcioController = TextEditingController( );
  TextEditingController _iniciController = TextEditingController( );
  TextEditingController _finalController = TextEditingController( );



  _ItinerariViewState(this._itinerari, this._model);

  void initState(){
    super.initState();
    _descripcioController.text = _itinerari["descripcio"].toString();
    _iniciController.text = _itinerari["inici"].toString();
    _finalController.text = _itinerari["final"].toString();

  }

  void doItinerariOp() async{
    if (_itinerari.isSaved()){
      // Modify values of pla
      await widget.db.update(_itinerari, _itinerari['id']!);
    }else {
      await widget.db.create(_itinerari);
    }

  }

  Future openMap(BuildContext context) async {

    _model.setRoute( _itinerari.path ) ;
    var route = CupertinoPageRoute(builder: (context) => MapView(_model, widget.db, MapViewOptions(false, false)), title: "Entreu el recorregut", );
    await Navigator.push(context, route);

    var start = _model.route.first;
    var end = _model.route.last;

    List<Placemark> placemarksInici = await placemarkFromCoordinates(start.latitude, start.longitude);
    String nomInici = placemarksInici.length == 0 ? "" : "${placemarksInici[0].name} a ${placemarksInici[0].locality} ";

    List<Placemark> placemarksFinal = await placemarkFromCoordinates(end.latitude, end.longitude);
    String nomFinal = placemarksFinal.length == 0 ? "" : "${placemarksFinal[0].name} a ${placemarksFinal[0].locality} ";


    setState(()  {

      if (_model.route.nrOfCoordinates > 0) {
        _itinerari["geo"] = _model.route;
        _itinerari["inici"] = nomInici;
        _itinerari["final"] = nomFinal;

      }else {
        _itinerari["geo"] = Path<LatLng>.from([]);
        _itinerari["inici"] = "";
        _itinerari["final"] = "";
      }
      _descripcioController.text = _itinerari["descripcio"].toString();
      _iniciController.text = _itinerari["inici"].toString();
      _finalController.text = _itinerari["final"].toString();

    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.canvasColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(_itinerari['nom'] ?? 'Nou Itinerari'),
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
                !_itinerari.isSaved() ? "Crea el teu itinerari".text.xl2.make() : "Modifica itinerari".text.xl2.make(),
                CupertinoFormSection(
                    header: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ["Itinerari".text.make(),

                      Container(
                        padding: EdgeInsets.zero,
                        height: 40,
                        child: CupertinoButton(child: Icon(CupertinoIcons.map),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            await openMap(context);
                          }, ),
                      ),


                    ]),
                    children: [
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          initialValue: _itinerari["nom"]  ?? "",
                          placeholder: "Nom de l'Itinerari'",
                          onChanged: (value) => setState((){_itinerari["nom"] = value;}),
                        ),
                        prefix: "Nom".text.make(),
                      ),

                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          controller: _iniciController,
                          placeholder: "Punt de sortida",
                          enabled: false,
                          expands: true,
                          minLines: null,
                          maxLines: null,

                        ),
                        prefix: "Inici".text.make(),
                      ),

                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          controller: _finalController,
                          placeholder: "Punt d'arribada",
                          enabled: false,
                          expands: true,
                          minLines: null,
                          maxLines: null,

                        ),
                        prefix: "Final".text.make(),
                      ),

                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          controller: _descripcioController,
                          placeholder: "Descripció itinerari",
                          onChanged: (value) => _itinerari["descripcio"] = value,
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

                Consumer<AppStateModel>(
                  builder: (context, model, child) {
                    return Material(
                      color: context.cupertinoTheme.primaryColor,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        onTap: doItinerariOp,
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          width: 150,
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            !_itinerari.isSaved() ? "Crea" : "Modifica",
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

class ItinerariViewPage extends Page {
  final SQLDatabase db;
  final Itinerari itinerari;
  final AppStateModel model;

  ItinerariViewPage(this.db, this.itinerari, this.model) : super(key: ValueKey('Pla Page'));

  @override
  Route createRoute(BuildContext context){
    return CupertinoPageRoute(settings: this, builder: (BuildContext context) => ItinerariView(db, itinerari, model));
  }
}