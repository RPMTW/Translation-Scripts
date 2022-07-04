import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import '../function/PathUttily.dart';

class ModInfos extends MapBase<String, ModInfo> {
  File get file => PathUttily().getModInfoFile();

  late Map<String, ModInfo> _map;

  ModInfos() {
    _map = _read();
  }

  String _readAsString() {
    return file.existsSync() ? file.readAsStringSync() : "{}";
  }

  Map<String, ModInfo> _read() {
    Map map = json.decode(_readAsString());

    return map.map((key, value) => MapEntry(key, ModInfo.fromJson(value)));
  }

  void add(String modID, int curseForgeID) {
    _map[modID] = ModInfo(
      curseForgeID,
      DateTime.now(),
      modID,
    );
    save();
  }

  void save() {
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(json.encode(_map));
  }

  @override
  operator [](Object? key) {
    return _map[key];
  }

  @override
  void operator []=(key, value) {
    _map[key] = value;
  }

  @override
  void clear() {
    _map.clear();
  }

  @override
  remove(Object? key) {
    return _map.remove(key);
  }

  @override
  Iterable<String> get keys => _map.keys;
}

class ModInfo {
  final int curseForgeID;
  final String modID;

  DateTime lastUpdated;

  bool get needUpdate =>
      lastUpdated.isBefore(DateTime.now().subtract(Duration(days: 10)));

  ModInfo(this.curseForgeID, this.lastUpdated, this.modID);

  factory ModInfo.fromJson(Map<String, dynamic> json) {
    return ModInfo(
      json['curseForgeID'],
      DateTime.parse(json['lastUpdated']),
      json['modID'],
    );
  }

  Map toJson() {
    return {
      'curseForgeID': curseForgeID,
      'lastUpdated': lastUpdated.toIso8601String(),
      'modID': modID,
    };
  }
}
