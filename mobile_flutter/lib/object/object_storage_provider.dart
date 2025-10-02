import 'dart:convert';

import 'package:mobile_flutter/domain/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IObjectStorageProvider {
  Future<void> clear();
  Future<List<Project>> getObjects();
  Future<void> saveObjects(List<Project> data);
  Future<List<Project>> getInspectorObjects();
  Future<void> saveInspectorObjects(List<Project> data);
  Future<List<InspectorInfo>> getObjectInspectors(String projectUuid);
  Future<void> saveObjectInspectors(List<InspectorInfo> data);
  Future<List<ProjectScheduleItem>> getWorkTitles(String projectUuid);
  Future<void> saveWorkTitles(List<ProjectScheduleItem> data);
}

const OBJECTS_STORAGE_KEY = "OBJECTS_STORAGE_KEY";
const INSPECTOR_OBJECTS_STORAGE_KEY = "INSPECTOR_OBJECTS_STORAGE_KEY";
const INPECTOR_OBJECTS_STORAGE_KEY = "INPECTOR_OBJECTS_STORAGE_KEY";
const WORK_TITLES_KEY = "WORK_TITLES_KEY";
const INSPECTORS_STORAGE_KEY = "INSPECTORS_STORAGE_KEY";

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

    @override
  Future<List<Project>> getInspectorObjects() async {
    if (preferences == null) {
      await init();
    }

    var rawData = preferences?.getString(INSPECTOR_OBJECTS_STORAGE_KEY);

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
  Future<void> saveInspectorObjects(List<Project> newData) async {
    final existing = await getObjects();

    final combined = {
      for (var p in [...existing, ...newData]) p.uuid: p
    }.values.toList();

    final encoded = jsonEncode(combined.map((e) => {"project": e.toJson()}).toList());
    await preferences?.setString(INSPECTOR_OBJECTS_STORAGE_KEY, encoded);
  }

  @override
  Future<List<InspectorInfo>> getObjectInspectors(String projectUuid) async {
    if (preferences == null) {
      await init();
    }

    var rawData = preferences?.getString(INSPECTORS_STORAGE_KEY);

    if (rawData != null) {
      final List<dynamic> jsonList = jsonDecode(rawData);

      final inspectors = jsonList
          .map((e) => InspectorInfo.fromStorageJson(e as Map<String, dynamic>))
          .where((e) => e.projectUuid == projectUuid)
          .toList();

      return inspectors;
    } else {
      return [];
    }
  }

  @override
  Future<void> saveObjectInspectors(List<InspectorInfo> newData) async {
    final existing = await getObjectInspectors(newData.first.projectUuid);

    final combined = {
      for (var p in [...existing, ...newData]) p.uuid: p
    }.values.toList();

    final encoded = jsonEncode(combined.map((e) => e.toJson()).toList());
    await preferences?.setString(OBJECTS_STORAGE_KEY, encoded);
  }

  @override
  Future<List<ProjectScheduleItem>> getWorkTitles(String projectUuid) async {
    if (preferences == null) {
      await init();
    }

    var rawData = preferences?.getString(WORK_TITLES_KEY);

    if (rawData != null) {
      final List<dynamic> jsonList = jsonDecode(rawData);

      final works = jsonList
          .map((e) => ProjectScheduleItem.fromStorageJson(e as Map<String, dynamic>))
          .where((e) => e.projectUuid == projectUuid)
          .toList();

      return works;
    } else {
      return [];
    }
  }

  @override
  Future<void> saveWorkTitles(List<ProjectScheduleItem> newData) async {
    final existing = await getWorkTitles(newData.first.projectUuid);

    final combined = {
      for (var p in [...existing, ...newData]) p.title: p
    }.values.toList();

    final encoded = jsonEncode(combined.map((e) => e.toJson()).toList());
    await preferences?.setString(OBJECTS_STORAGE_KEY, encoded);
  }
}