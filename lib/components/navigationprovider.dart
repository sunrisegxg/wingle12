import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void updateIndex(int index) {
    _selectedIndex = index;
    // print("Updated Index: $_selectedIndex"); // In ra chỉ số mới
    notifyListeners();
  }
  void resetIndex() {
    _selectedIndex = 0; // Đặt lại về tab đầu tiên
    notifyListeners();
  }
}