import 'dart:async';
import 'package:shuttertop/models/topic.dart';
import 'package:shuttertop/services/base_service.dart';

class TopicService extends BaseService implements TopicRepository {
  @override
  String get url => "/topics";

  @override
  Future<RequestListPage<Topic>> fetch({int page = 0}) async {
    final Map<String, dynamic> topicsContainer =
        await httpGet(params: <String, String>{"page": page.toString()});
    final List<dynamic> topicItems = topicsContainer['topics'];
    return new RequestListPage<Topic>(
        topicItems
            .map((dynamic topicRaw) => new Topic.fromMap(topicRaw))
            .toList(),
        topicsContainer['total_entries']);
  }
}
