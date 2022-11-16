import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:plans/SignIn.dart';
import 'package:plans/model/AppStateModel.dart';
import 'package:plans/model/SQLDatabase.dart';
import '/main.dart';
import '/LoginView.dart';
import 'package:provider/provider.dart';
import '/SignIn.dart';


class MyAppRouterDelegate extends RouterDelegate with ChangeNotifier, PopNavigatorRouterDelegateMixin {

  final AppStateModel model;
  final SQLDatabase db;
  final GlobalKey<NavigatorState> _navigatorKey;



  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  MyAppRouterDelegate(this.model, this.db) : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  _init() async {

  }

  @override
  Widget build(BuildContext context) {
    List<Page> stack;
    if (model.isLogged) {
      stack = _homeStack;
    } else if (model.isSigningIn) {
      stack = _signInStack;
    } else {
      stack = _loginStack;
    }
    return Navigator(
      key: navigatorKey,
      pages: stack,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;

        return true;
      },
    );
  }

  List<Page> get _loginStack => [LoginPage(db)];

  List<Page> get _signInStack => [
  SignInPage(db),
  ];

  List<Page> get _homeStack {
   return [
     LoginPage(db),
     HomePage(db),
    ];
  }


  @override
  Future<void> setNewRoutePath(configuration) async { /* Do Nothing */ }
}