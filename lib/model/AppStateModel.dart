import 'package:flutter/foundation.dart' as foundation;
import '/model/User.dart';

class AppStateModel extends foundation.ChangeNotifier {

  User? _currentUser;

  bool get isLogged => _currentUser != null;
  String? get userName => _currentUser != null ? _currentUser!['nom'] + ' ' + _currentUser!['cognoms'] : "";
  bool get isUserActive => _currentUser == null ? false : _currentUser!['active'];



}