import 'package:flutter/material.dart';

class CurrentOpenChat with ChangeNotifier {
  String _currentOpenChatID;

  openChat(String id) {
    _currentOpenChatID = id;
    notifyListeners();
  }

  closeChat() {
    _currentOpenChatID = null;
    notifyListeners();
  }

  get currentOpenChatID => _currentOpenChatID;
}
