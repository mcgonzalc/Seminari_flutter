import 'dart:ffi';

import 'package:flutter/material.dart';
import '../models/user.dart';

class UserAuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  String? get userId => _currentUser?.id;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}