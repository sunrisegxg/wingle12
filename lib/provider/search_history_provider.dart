import 'package:flutter/material.dart';

class SearchHistoryProvider extends ChangeNotifier {
  List<String> _searchHistory = [];

  List<String> get searchHistory => _searchHistory;

  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      _searchHistory.remove(term);
    }
    _searchHistory.add(term);
    notifyListeners();
  }
  void removeSearchTerm(String term) {
    _searchHistory.remove(term);
    notifyListeners();
  }

  void clearHistory() {
    _searchHistory.clear();
    notifyListeners();
  }
}
