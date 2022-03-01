// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/User.dart';
// ** PACKAGES ** //
// ** MODEL ** //
// ** OTHERS ** //

class NotificationService {

  static Future<List<dynamic>> getUserNotifications(User user) async {
    List<dynamic> result = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getUserNotifications.replaceAll("{userId}", user.username));
    if (response['status'] == HttpStatus.OK)
      result = response['result'];
    return result;
  }

  static Future<Map<String, dynamic>> dismissNotification(int notificationId) async{
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.POST, OriginConstants.dismissNotification.replaceAll("{notificationId}", notificationId.toString()));
    if (response['status'] == HttpStatus.OK)
      result = response['result'];
    return result;
  }

}