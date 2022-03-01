import 'dart:convert';
import 'package:origin/config/Constants.dart';
import 'localStorageHandler.dart';
import 'package:http/http.dart' as http;

/*
Les codes les plus courants sont :

    200 : succès de la requête ;
    301 et 302 : redirection, respectivement permanente et temporaire ;
    401 : utilisateur non authentifié ;
    403 : accès refusé ;
    404 : page non trouvée ;
    500 et 503 : erreur serveur ;
    504 : le serveur n'a pas répondu.

Codes persos :

    604 : Pas de chemin d'accès à l'api (pas de connexion / api down / ...)

*/

class HTTPRequestHandler{
  static final Duration timeout = const Duration(seconds: 12);
  static const urlBack = "http://${OriginConstants.urlApi_backEnd}";
  static String _token;

  static Future<dynamic> request(HttpRequest type, String action, {dynamic requestBody = const {}, Map<String, String> requestHeaders}) async{
    if(requestHeaders == null)
      requestHeaders = {'Content-Type' : 'application/json', 'Access-Control-Allow-Origin' : '*'};
    if(_token != null)
      requestHeaders['Authorization'] = 'Bearer $_token';

    var result = {};
    try {

      DateTime startingTime = DateTime.now();
      var response;
      switch(type){
        case HttpRequest.GET:
          response = await http.get(Uri.parse('$urlBack/$action'), headers: requestHeaders).timeout(timeout);
          break;
        case HttpRequest.POST:
          response = await http.post(Uri.parse('$urlBack/$action'), body: json.encode(requestBody), headers: requestHeaders).timeout(timeout);
          break;
        case HttpRequest.PUT:
          response = await http.put(Uri.parse('$urlBack/$action'), body: requestBody, headers: requestHeaders).timeout(timeout);
          break;
        case HttpRequest.DELETE:
          response = await http.delete(Uri.parse('$urlBack/$action'), headers: requestHeaders).timeout(timeout);
          break;
      }
      print("${type.toString().substring(12)} Request: $urlBack/$action - Status: ${numberStatusToConstantStatus(response.statusCode).toString().substring(11)} / ${DateTime.now().difference(startingTime).inMilliseconds}ms");

      switch(numberStatusToConstantStatus(response.statusCode)){
        case HttpStatus.OK:
          result = {'status': HttpStatus.OK, 'result': response.contentLength > 0 ? json.decode(utf8.decode(response.bodyBytes)) : null};
          break;
        case HttpStatus.CREATED:
          result = {'status': HttpStatus.CREATED, 'result': response.contentLength > 0 ? json.decode(utf8.decode(response.bodyBytes)) : null};
          break;
        case HttpStatus.NO_CONTENT:
          result = {'status': HttpStatus.NO_CONTENT, 'result': {}};
          break;
        case HttpStatus.NOT_FOUND:
          result = {'status': HttpStatus.NOT_FOUND, 'result': null};
          break;
        case HttpStatus.CONFLICT:
          result = {'status': HttpStatus.CONFLICT, 'result': {'error': 'Paramètres transmis incorrects ou manquants'}};
          break;
        case HttpStatus.UNAUTHORIZED:
          result = {'status': HttpStatus.UNAUTHORIZED, 'result': {'error': 'Utilisateur connecté ne possède pas les droits d\'effectuer cette requête'}};
          break;
        case HttpStatus.FORBIDDEN:
          result = {'status': HttpStatus.FORBIDDEN, 'result': {'error': 'Utilisateur connecté ne pourra jamais effectuer cette requête'}};
          break;
        case HttpStatus.BAD_REQUEST:
          result = {'status': HttpStatus.BAD_REQUEST, 'result': {'error': response.body}};
          print(response.body);
          break;
        case HttpStatus.SERVER_ERROR:
          result = {'status': HttpStatus.SERVER_ERROR, 'result': {'error': response.body}};
          print(response.body);
          break;
        default:
          result = {'status': HttpStatus.FRONT_ERROR, 'result': {'error': 'Statut HTTP non géré dans le front'}};
          break;
      }

    }catch(exception){
      result = {'status': HttpStatus.FRONT_ERROR, 'result': {'error': exception}};
    }

    return result;
  }

  // Nettoyage du token de connexion
  static void disconnect(){
    _token = null;
    LocalStorageHandler.removeData(OriginConstants.tokenId);
  }

  static void setToken(String givenToken){
    _token = givenToken;
    LocalStorageHandler.putData(OriginConstants.tokenId, givenToken);
  }

  static Future<String> getToken() async{
    if(_token == null)
      _token = await LocalStorageHandler.getData(OriginConstants.tokenId);
    return _token;
  }

  static HttpStatus numberStatusToConstantStatus(int number){
    switch(number){
      case 200:
        return HttpStatus.OK;
        break;
      case 201:
        return HttpStatus.CREATED;
        break;
      case 204:
        return HttpStatus.NO_CONTENT;
        break;
      case 400:
        return HttpStatus.BAD_REQUEST;
        break;
      case 401:
        return HttpStatus.UNAUTHORIZED;
        break;
      case 403:
        return HttpStatus.FORBIDDEN;
        break;
      case 404:
        return HttpStatus.NOT_FOUND;
        break;
      case 409:
        return HttpStatus.CONFLICT;
        break;
      case 500:
        return HttpStatus.SERVER_ERROR;
        break;
      default:
        return HttpStatus.FRONT_ERROR;
        break;
    }
  }

  // Permet d'effectuer une requête http POST vers le back end d'origin (interprété en json)
  // retourne un objet avec le statut (status) et le corps de la réponse (result)
  static Future<dynamic> postWithParams(String action, Map<String, String> params, {Map<String, String> requestHeaders = const {'Content-Type' : 'application/x-www-form-urlencoded', 'Access-Control-Allow-Origin' : '*'}}) async{

    if(_token != null)
      requestHeaders = {'Content-Type' : 'application/x-www-form-urlencoded', 'Access-Control-Allow-Origin' : '*', 'Authorization': 'Bearer $_token'};

    var result = {};
    try {
      String encodedParams = "";
      params.forEach((key, value){
        encodedParams += key+"="+value+"&";
      });
      encodedParams = encodedParams.substring(0, encodedParams.length-1);

      DateTime startingTime = DateTime.now();

      var response = await http.post(Uri.parse('$urlBack/$action'), body: encodedParams, headers: requestHeaders);
      print("POST (with params) Request: $urlBack/$action - Status: ${response.statusCode} / ${DateTime.now().difference(startingTime).inMilliseconds}ms");

      if(response.statusCode != 200 && response.statusCode != 204)
        print('Response body: ${response.body}');
      result = {'status': response.statusCode, 'result': response.contentLength > 0 ? json.decode(utf8.decode(response.bodyBytes)) : null};

    }catch(exception){
      print("POST (with params) Request: $urlBack/$action - Error: $exception");
      result = {'status': 604, 'result': {'error': exception}};
    }

    return result;
  }

  // Permet d'effectuer une requête http PUT vers le back end d'origin (interprété en json)
  // retourne un objet avec le statut (status) et le corps de la réponse (result)
  static Future<dynamic> putWithParams(String action, Map<String, String> params, {Map<String, String> requestHeaders = const {'Content-Type' : 'application/x-www-form-urlencoded', 'Access-Control-Allow-Origin' : '*'}}) async{

    if(_token != null)
      requestHeaders = {'Content-Type' : 'application/x-www-form-urlencoded', 'Access-Control-Allow-Origin' : '*', 'Authorization': 'Bearer $_token'};

    var result = {};
    try {
      String encodedParams = "";
      params.forEach((key, value){
        encodedParams += key+"="+value+"&";
      });

      DateTime startingTime = DateTime.now();

      var response = await http.put(Uri.parse('$urlBack/$action'), body: encodedParams, headers: requestHeaders);
      print("PUT (with params) Request: $urlBack/$action - Status: ${response.statusCode} / ${DateTime.now().difference(startingTime).inMilliseconds}ms");

      if(response.statusCode != 200 && response.statusCode != 204)
        print('Response body: ${response.body}');
      result = {'status': response.statusCode, 'result': response.contentLength > 0 ? json.decode(utf8.decode(response.bodyBytes)) : null};

    }catch(exception){
      print("PUT (with params) Request: $urlBack/$action - Error: $exception");
      result = {'status': 604, 'result': {'error': exception}};
    }

    return result;
  }
}

enum HttpRequest{
  GET,
  POST,
  PUT,
  DELETE
}

enum HttpStatus{
  OK, // 200
  CREATED, // 201
  NO_CONTENT, // 204
  BAD_REQUEST, // 400
  UNAUTHORIZED, // 401
  FORBIDDEN, // 403
  NOT_FOUND, // 404
  CONFLICT, // 409
  SERVER_ERROR, // 500 -> internal_server_error
  FRONT_ERROR // 604
}