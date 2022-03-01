import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/User.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';

/// à l'aide du package flutter_socket_io,
/// cette classe permet de créer une connexion (web socket) entre le mobile et le back d'origin
class SocketIOHandler{

  static StompClient _client;
  static Project _project;
  static User _user;
  static List<Function> unsubscribers;

  static void open(Project project, User user, Function onConnectCallback){
    if(_client != null) _client.connected ? close() : _client = null;
    _project = project;
    _user = user;
    unsubscribers = List();

    _client = StompClient(config:
      StompConfig(
        url: 'ws://${OriginConstants.urlApi_backEnd}/connect',
        stompConnectHeaders: {'login': _user.username, 'pwd': _user.password},
        onWebSocketError: (dynamic error) => print(error.toString()),
        onConnect: (_) => (StompClient client, StompFrame connectFrame){
          onConnectCallback(client);
        },
        connectionTimeout: const Duration(seconds: 10),
        reconnectDelay: const Duration(seconds: 10000),
        heartbeatIncoming: const Duration(seconds: 15000),
        heartbeatOutgoing: const Duration(seconds: 15000)
      )
    );

    _client.activate();
  }

  static send(String path, {String body = "dump"}){
    if(_client != null && _client.connected)
      _client.send(destination: '/planning_poker/$path/${_project.id}', body: body);
  }

  static subscribe(String path, Function callback){
    if(_client != null && _client.connected)
      unsubscribers.add(_client.subscribe(destination: '/listen/$path/${_project.id}', callback: (response){
        Map<String, dynamic> result = json.decode(response.body);
        if(HTTPRequestHandler.numberStatusToConstantStatus(result["statusCodeValue"]) == HttpStatus.OK)
          callback(result["body"]);
        else print("Socket Subscribe Error: ${result["body"]} - Status: ${result["statusCode"]}");
      }));
  }

  static close(){
    if(_client != null && _client.connected){
      if(unsubscribers != null){
        try{
          unsubscribers.forEach((unsubscribe) => unsubscribe());
        }catch(e){
          print(e);
        }
      }
      _client.deactivate();
    }
    _client = null;
    _project = null;
  }

}