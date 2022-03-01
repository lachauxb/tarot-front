// Import the test package and localStorageHandler class
import 'package:flutter_test/flutter_test.dart';
import 'package:origin/services/AuthenticationService.dart';

void main() {

  test('Test AuthenticationService: tentative de connexion avec un mauvais password  ...', () async {
    var response = await AuthenticationService.connect("aléatoire", "aléatoire");
    expect(response, 200);
  });

}
