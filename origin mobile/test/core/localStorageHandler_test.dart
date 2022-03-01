// Import the test package and localStorageHandler class
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:origin/core/localStorageHandler.dart';

void main() {

  const key = "local_test";
  const value = "tester_testing_test";

  test('Test LocalStorage: sauvegarde & récupération d\'une donnée  ...', () async {
    WidgetsFlutterBinding.ensureInitialized();
    LocalStorageHandler.putData(key, value);
    var result = await LocalStorageHandler.getData(key);
    expect(result, value);
  });

  test('Test LocalStorage: suppression d\'une donnée  ...', () async {
    WidgetsFlutterBinding.ensureInitialized();
    LocalStorageHandler.putData(key, value);
    LocalStorageHandler.removeData(key);
    var result = await LocalStorageHandler.getData(key);
    expect(result, null);
  });

}
