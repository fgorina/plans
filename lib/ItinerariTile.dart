import 'package:flutter/cupertino.dart';
import 'package:plans/model/AppStateModel.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/material.dart';
import '/model/Itinerari.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ItinerariTile extends StatefulWidget {
  final Itinerari _itinerari;
  final BoxConstraints _constraints;
  final AppStateModel _model;

  ItinerariTile(this._itinerari, this._constraints, this._model);

  @override
  _ItinerariTileState createState() {
    return _ItinerariTileState(_itinerari, _constraints, _model);
  }
}

class _ItinerariTileState extends State<ItinerariTile> {
  final Itinerari _itinerari;
  final BoxConstraints _constraints;
  final AppStateModel _model;
  bool pressedDown = false;

  _ItinerariTileState(this._itinerari, this._constraints, this._model);

  @override
  Widget build(BuildContext context) {
    //DateTime someDate = DateTime.parse(_itinerari['dateCreated']);
    //final DateFormat formatter = DateFormat('dd-MM-yy hh:mm');
   // String someFormattedDate = formatter.format(someDate);

    return Slidable(
        startActionPane: ActionPane(
            extentRatio: 0.25 / 2.0,
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                //flex: 2,
                onPressed: (ctx) => print("Editant ${_itinerari['nom']}"),
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
              onPressed: (ctx) => print("Editant ${_itinerari['nom']}"),
              backgroundColor: CupertinoColors.activeGreen,
              foregroundColor: Colors.white,
              icon: CupertinoIcons.pencil,
            ),
            SlidableAction(
              // An action can be bigger than the others.
              //flex: 2,
              onPressed: (ctx) => print("Esborrant ${_itinerari['nom']}"),
              backgroundColor: CupertinoColors.destructiveRed,
              foregroundColor: Colors.white,
              icon: CupertinoIcons.bin_xmark,
            ),
          ],
        ),
        child: GestureDetector(
            onTapDown: (details) {
              setState(() {
                print("Pressed Down ${_itinerari['nom']}");
                pressedDown = true;
              });
            },
            onTapUp: (details) {
              setState(() {
                pressedDown = false;
              });
              _model.setCurrentItinerari(_itinerari);
            },

            //onTap: () => print("Open ${_pla['nom']}"),
            child: Container(
              height: 50,
              color: pressedDown
                  ? CupertinoColors.systemGrey5
                  : CupertinoColors.systemBackground,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ((_itinerari['nom'] ?? "") as String).text.size(18).make(),
                      Container(
                        width: _constraints.maxWidth - 16.0,
                        child: (_itinerari['descripcio'] != null
                            ? _itinerari['descripcio'].toString()
                            : "")
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
