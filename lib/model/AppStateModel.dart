import 'package:flutter/foundation.dart' as foundation;
import '/model/User.dart';
import '/model/Pla.dart';

class AppStateModel extends foundation.ChangeNotifier {

  User? _currentUser;
  bool _isSigningIn = false;

  bool get isLogged => _currentUser != null;
  bool get isSigningIn => _isSigningIn;

  void signIn(){
    if (!isLogged){
      _isSigningIn = true;
      notifyListeners();
    }
  }

  User? get user =>  _currentUser;
  String get userName => _currentUser != null ? _currentUser!['nom'] + ' ' + _currentUser!['cognoms'] : "";
  bool get isUserActive => _currentUser == null ? false : _currentUser!['active'];



  void setUser(User user){
    _currentUser = user;
    _isSigningIn = false;
    notifyListeners();
  }
  void clearUser(){
    _currentUser = null;
    _isSigningIn = false;
    notifyListeners();
  }

  // Plans

  Pla? _currentPla;
  bool _editPla = false;
  bool _runPla = false;


  Pla? get pla => _currentPla;

  void editPla(){
    if (_currentPla != null && !_runPla){
      _editPla = true;
    }
  }

  void runPla(){
    if(_currentPla != null && !_editPla){
      _runPla = true;
    }
  }
}