import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker =
      InternetConnectionChecker.createInstance();

  StreamController<bool>? _controller;

  Future<bool> hasInternet() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    return await _internetChecker.hasConnection;
  }

  Stream<bool> internetStatusStream() {
    _controller ??= StreamController<bool>.broadcast();

    _connectivity.onConnectivityChanged.listen((_) async {
      final hasConnection = await hasInternet();
      _controller?.add(hasConnection);
    });

    return _controller!.stream;
  }

  void dispose() {
    _controller?.close();
  }
}