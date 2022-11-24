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
import '/model/Pla.dart';
import 'package:intl/intl.dart';
import 'Alerts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PlaTile extends StatefulWidget {
  final Pla _pla;
  final BoxConstraints _constraints;
  final AppStateModel _model;

  PlaTile(this._pla, this._constraints, this._model);

  @override
  _PlaTileState createState() {
    return _PlaTileState(_pla, _constraints, _model);
  }
}

class _PlaTileState extends State<PlaTile> {
  final Pla _pla;
  final BoxConstraints _constraints;
  final AppStateModel _model;
  bool pressedDown = false;

  _PlaTileState(this._pla, this._constraints, this._model);

  @override
  Widget build(BuildContext context) {
    DateTime someDate = DateTime.parse(_pla['dateCreated']);
    final DateFormat formatter = DateFormat('dd-MM-yy hh:mm');
    String someFormattedDate = formatter.format(someDate);

    return Slidable(
        startActionPane: ActionPane(
            extentRatio: 0.25 / 2.0,
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                //flex: 2,
                onPressed: (ctx) => print("Editant ${_pla['nom']}"),
                backgroundColor: CupertinoColors.activeBlue,
                foregroundColor: Colors.white,
                icon: Icons.directions_run,
              ),
            ]),
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              // An action can be bigger than the others.
              flex: 1,
              onPressed: (ctx) => print("Editant ${_pla['nom']}"),
              backgroundColor: CupertinoColors.activeGreen,
              foregroundColor: Colors.white,
              icon: CupertinoIcons.pencil,
            ),
            SlidableAction(
              // An action can be bigger than the others.
              //flex: 2,
              onPressed: (ctx) => print("Esborrant ${_pla['nom']}"),
              backgroundColor: CupertinoColors.destructiveRed,
              foregroundColor: Colors.white,
              icon: CupertinoIcons.bin_xmark,
            ),
          ],
        ),
        child: GestureDetector(
            onTapDown: (details) {
              setState(() {
                print("Pressed Down ${_pla['nom']}");
                pressedDown = true;
              });
            },
            onTapUp: (details) {

              setState((){
              pressedDown = false;

              });
              _model.setCurrentPla(_pla);
              },

            //onTap: () => print("Open ${_pla['nom']}"),
            child: Container(
              height: 50,
              color: pressedDown ? CupertinoColors.systemGrey5: CupertinoColors.systemBackground,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ((_pla['nom'] ?? "") as String).text.size(18).make(),
                      Container(
                        width: _constraints.maxWidth - 16.0,
                        child: ((_pla['descripcio'] ?? "") as String)
                            .text
                            .size(10)
                            .maxLines(2)
                            .overflow(TextOverflow.ellipsis)
                            .color(CupertinoColors.systemGrey)
                            .make(),
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }
}

class ActivityPlansHomePage extends StatelessWidget {
  AppStateModel model;


  ActivityPlansHomePage(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Plans de Navegació"),
          trailing: CupertinoButton(
            onPressed: () => model.showMap(),
            child: Icon(CupertinoIcons.plus),
          ),
        ),
        backgroundColor: context.canvasColor,
        child: SafeArea(
          child: Consumer<AppStateModel>(
            builder: (context, model, child) {
              return Container(
                color: CupertinoColors.lightBackgroundGray,
                padding: EdgeInsets.all(12.0),
                child: Container(
                  padding: Vx.m8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0,
                      color: CupertinoColors.systemBackground,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: CupertinoColors.systemBackground,
                  ),
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return PlaTile(model.plans[index], constraints, model);
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemCount: model.plans.count(),
                    );
                  }),
                ),
              );
            },
          ),
        ));
  }
}

class HomePage extends Page {
  SQLDatabase db;
  AppStateModel model;

  HomePage(this.db, this.model) : super(key: ValueKey('HomePage'));

  @override
  Route createRoute(BuildContext context) {
    return CupertinoPageRoute(
        settings: this,
        builder: (BuildContext context) => ActivityPlansHomePage(model));
  }
}
