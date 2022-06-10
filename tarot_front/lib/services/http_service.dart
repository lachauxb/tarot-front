import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tarot_front/configurations/constants.dart';


class HTTPService {

  static const Duration timeout = Duration(seconds: 10);
  static String _token = "";

  /// Method for HTTP requests
  static Future<dynamic> request(HttpRequest type, String action, { dynamic requestBody = const {} }) async {
    Map<String, String> requestHeaders = {'Content-Type': 'application/json', 'Access-Control-Allow-Koalab': '*'};
    // Verification of connection token
    if (_token != "") {
      requestHeaders['Authorization'] = 'Bearer $_token';
    } else {

    }
    // Request to the backend
    var result = {};
    try {
      DateTime startingTime = DateTime.now();
      http.Response response;
      switch (type) {
        case HttpRequest.GET:
          response = await http.get(Uri.parse('$urlBack/$action'), headers: requestHeaders).timeout(timeout);
          break;
        case HttpRequest.POST:
          response = await http.post(Uri.parse('$urlBack/$action'), body: json.encode(requestBody), headers: requestHeaders).timeout(timeout);
          break;
        case HttpRequest.PUT:
          response = await http.put(Uri.parse('$urlBack/$action'), body: json.encode(requestBody), headers: requestHeaders).timeout(timeout);
          break;
        case HttpRequest.DELETE:
          response = await http.delete(Uri.parse('$urlBack/$action'), headers: requestHeaders).timeout(timeout);
          break;
      }
      // Print request for debug mode
      if (kDebugMode) {
        print("${type.toString()} Request: $urlBack/$action - Status: ${response.statusCode} / ${DateTime.now().difference(startingTime).inMilliseconds}ms");
      }
      // Result from the back
      switch (response.statusCode) {
        case 200:
          result = {'status': 200, 'result': response.contentLength! > 0 ? json.decode(utf8.decode(response.bodyBytes)) : null};
          break;
        default:
          result = {'status': 'Error', 'result': response.contentLength! > 0 ? json.decode(utf8.decode(response.bodyBytes)) : null};
          break;
      }
      // An error has occurred
    } catch (exception) {
      result = {'status': 'Exception thrown', 'result': exception};
    }
    return result;
  }

}


enum HttpRequest {
  GET,
  POST,
  PUT,
  DELETE
}
