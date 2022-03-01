// Import the test package and httpRequestHandler class
import 'package:flutter_test/flutter_test.dart';
import 'package:origin/config/auto_loader.dart';

void main() {

  // expected 204 because no content
  test('Test HTTP: envoi d\'une requête ping ...', () async {
    /*var response = await HTTPRequestHandler.get(OriginConstants.ping);
    expect(response['status'], 204);
    response = await HTTPRequestHandler.get(OriginConstants.ping);
    expect(response['status'], 204);
    response = await HTTPRequestHandler.get(OriginConstants.ping);
    expect(response['status'], 204);
    response = await HTTPRequestHandler.get(OriginConstants.ping);
    expect(response['status'], 204);*/
  });

  test('Test unitaire: setToken() + getToken()', () {
    WidgetsFlutterBinding.ensureInitialized();
    final testToken ="x186aA564s9A78KoxSD019";
    HTTPRequestHandler.setToken(testToken);
    expect(HTTPRequestHandler.getToken(), testToken);
  });

  test('Test unitaire: disconnect()', () {
    WidgetsFlutterBinding.ensureInitialized();
    final testToken ="x186aA564s9A78KoxSD019";
    HTTPRequestHandler.setToken(testToken);
    HTTPRequestHandler.disconnect();
    expect(HTTPRequestHandler.getToken(), null);
  });

}
