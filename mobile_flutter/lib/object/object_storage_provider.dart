import 'dart:convert';

import 'package:mobile_flutter/domain/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IObjectStorageProvider {
  Future<void> clear();
  Future<List<Project>> getObjects();
  Future<void> saveObjects(List<Project> data);
}

const OBJECTS_STORAGE_KEY = "OBJECTS_STORAGE_KEY";

class ObjectStorageProvider implements IObjectStorageProvider{
  SharedPreferences? preferences;

  ObjectStorageProvider();

  Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clear() async{
    if (preferences == null) {
      await init();
    }
    await preferences?.remove(OBJECTS_STORAGE_KEY);
  }

  @override
  Future<List<Project>> getObjects() async {
    if (preferences == null) {
      await init();
    }

    var rawData = preferences?.getString(OBJECTS_STORAGE_KEY);

    if (rawData != null) {
      final List<dynamic> jsonList = jsonDecode(rawData);

      final projects = jsonList
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList();

      return projects;
    } else {
      return [];
    }
  }

  @override
  Future<void> saveObjects(List<Project> newData) async {
    final existing = await getObjects();

    final combined = {
      for (var p in [...existing, ...newData]) p.uuid: p
    }.values.toList();

    final encoded = jsonEncode(combined.map((e) => {"project": e.toJson()}).toList());
    await preferences?.setString(OBJECTS_STORAGE_KEY, encoded);
  }

}