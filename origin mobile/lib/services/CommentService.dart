import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** MODEL ** //
import 'package:origin/model/Story.dart';
import 'package:origin/model/Sprint.dart';
import 'package:origin/model/Intersprint.dart';
import 'package:origin/model/Task.dart';
import 'package:origin/model/Comment.dart';
// ** OTHERS ** //
import 'dart:convert';

/// permet de gérer de manière centralisée les appels API liés à un commentaire
class CommentService {

  /// get all comments from a Story, Sprint, Intersprint or Task
  static Future<List<dynamic>> getAllComments(var item) async{
    List<dynamic> comments = new List<dynamic>();
    String action;
    switch(item.runtimeType){
      case Story:
        action = OriginConstants.getStoryComments.replaceAll("{storyId}", item.id.toString());
        break;
      case Sprint:
        action = OriginConstants.getSprintComments.replaceAll("{sprintId}", item.id.toString());
        break;
      case Intersprint:
        action = OriginConstants.getIntersprintComments.replaceAll("{intersprintId}", item.id.toString());
        break;
      case Task:
        action = OriginConstants.getTaskComments.replaceAll("{taskId}", item.id.toString());
        break;
    }
    final response = await HTTPRequestHandler.request(HttpRequest.GET, action);
    if (response['status'] == HttpStatus.OK) {
      comments = response['result'];
    }
    return comments;
  }

  /// enregistre un nouveau commentaire
  static Future<Comment> createComment(var item, String content) async {
    String action;
    switch(item.runtimeType){
      case Story:
        action = OriginConstants.createStoryComment.replaceAll("{storyId}", item.id.toString());
        break;
      case Sprint:
        action = OriginConstants.createSprintComment.replaceAll("{sprintId}", item.id.toString());
        break;
      case Intersprint:
        action = OriginConstants.createIntersprintComment.replaceAll("{intersprintId}", item.id.toString());
        break;
      case Task:
        action = OriginConstants.createTaskComment.replaceAll("{taskId}", item.id.toString());
        break;
    }
    final response = await HTTPRequestHandler.request(HttpRequest.POST, action, requestBody: {"comment": content, "like": jsonEncode(false)},);
    if (response['status'] == HttpStatus.OK) {
      return Comment.fromApi(response["result"]);
    }
    return null;
  }

  // actualise le compte de like sur un commentaire
  static Future<bool> likeComment(int commentId, bool like) async {
    final response = await HTTPRequestHandler.request(HttpRequest.POST, OriginConstants.likeComment.replaceAll("{noteId}", commentId.toString()), requestBody: {"comment": null, "like": jsonEncode(like)},);
    if (response['status'] == HttpStatus.OK) {
      return true;
    }
    return false;
  }

  // supprime un commentaire
  static Future<bool> deleteComment(var item, int commentId) async {
    String action;
    switch(item.runtimeType){
      case Story:
        action = OriginConstants.deleteStoryComment.replaceAll("{storyId}", item.id.toString());
        break;
      case Sprint:
        action = OriginConstants.deleteSprintComment.replaceAll("{sprintId}", item.id.toString());
        break;
      case Intersprint:
        action = OriginConstants.deleteIntersprintComment.replaceAll("{intersprintId}", item.id.toString());
        break;
      case Task:
        action = OriginConstants.deleteTaskComment.replaceAll("{taskId}", item.id.toString());
        break;
    }
    final response = await HTTPRequestHandler.request(HttpRequest.DELETE, action.replaceAll("{noteId}", commentId.toString()),);
    if (response['status'] == HttpStatus.OK) {
      return true;
    }
    return false;
  }
}

class UpdateTemplate{
  String comment;
  String commentedItem;
  bool like;

  UpdateTemplate({this.comment = "",this.like = false});
}