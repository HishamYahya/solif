import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DialogMySwalfTabModel with ChangeNotifier {
  String _selectedSalfhID;
  String _selectedSalfhColor;

  get selectedSalfhID => _selectedSalfhID;
  get selectedSalfhColor => _selectedSalfhColor;

  selectSalfh({String salfhID, String color}) {
    if (selectedSalfhID == salfhID) {
      _selectedSalfhID = null;
      _selectedSalfhColor = null;
    } else {
      _selectedSalfhID = salfhID;
      _selectedSalfhColor = color;
    }
    notifyListeners();
  }
}
