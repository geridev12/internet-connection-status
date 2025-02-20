import 'package:flutter/material.dart';
import 'package:internet_connection_status/internet_connection_api.g.dart';

class InternetProvider extends ChangeNotifier {
  bool? _hasConnection;

  final _internetConnectionApi = InternetConnectionApi();

  bool? get hasConnection => _hasConnection;

  Future<void> checkInternetConnection() async {
    _hasConnection = await _internetConnectionApi.hasInternetConnection();
    notifyListeners();
  }
}
