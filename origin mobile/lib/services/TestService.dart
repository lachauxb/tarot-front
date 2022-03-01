// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** MODEL ** //
// ** OTHERS ** //

class TestService {

  /// Met à jour l'état du test
  static Future<Map<String, dynamic>> changeTestState(int testId, bool testState) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.putWithParams(OriginConstants.changeTestState.replaceAll("{testId}", testId.toString()), {"value":"$testState"});
    if (response['status'] == HttpStatus.OK) {
      result = response['result'];
    }
    return result;
  }

}