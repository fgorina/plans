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
import 'package:pull_down_button/pull_down_button.dart';
import 'PlaTile.dart';
import 'ItinerariTile.dart';

class ActivityPlansHomePage extends StatelessWidget {
  AppStateModel model;

  ActivityPlansHomePage(this.model, {Key? key}) : super(key: key);

  void gotoPlans() {
    model.setScreen(Screen.PlaList);
  }

  void gotoItineraris() {
    model.setScreen(Screen.ItinerariList);
  }

  void gotoEmbarcacions() {
    model.setScreen(Screen.EmbarcacioList);
  }

  void gotoProfile() {
    model.setScreen(Screen.Profile);
  }

  ListView listView(Screen screen, constraints) {
    if (screen == Screen.PlaList) {
      return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return PlaTile(model.plans[index], constraints, model);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: model.plans.count(),
      );
    } else if (screen == Screen.ItinerariList) {
      return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return ItinerariTile(model.itineraris[index], constraints, model);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: model.itineraris.count(),
      );
    } else {
      return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return PlaTile(model.plans[index], constraints, model);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: model.plans.count(),
      );
    }
  }

  String title (Screen screen){
    switch(screen){
      case Screen.PlaList:
        return "Plans de Navegació";

      case Screen.ItinerariList:
        return "Itineraris";

      case Screen.EmbarcacioList:
        return "Embarcacions";

    }

    return "Desconegut";
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: title(model.currentScreen).text.make(),
          leading: PullDownButton(
            itemBuilder: (context) => [
              PullDownMenuItem(
                title: "Plans",
                onTap: () {
                  gotoPlans();
                },
              ),
              PullDownMenuItem(
                title: "Itineraris",
                onTap: () {
                  gotoItineraris();
                },
              ),
              PullDownMenuItem(
                title: "Embarcacions",
                onTap: () {
                  gotoEmbarcacions();
                },
              ),
              PullDownMenuItem(
                title: "Profile",
                onTap: () {
                  gotoProfile();
                },
              ),
              PullDownMenuDivider(),
              PullDownMenuItem(
                title: "Logout",
                onTap: () {
                  context.navigator!.pop(true);
                },
              ),
            ],
            buttonBuilder: (context, showMenu) => CupertinoButton(
              onPressed: showMenu,
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.line_horizontal_3),
            ),
          ),
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
                    return listView(model.currentScreen, constraints);
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
