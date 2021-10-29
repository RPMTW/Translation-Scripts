import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import '../function/PathUttily.dart';

class ModInfos extends MapBase<String, ModInfo> {
  File get file => PathUttily().getModInfoFile();

  late Map<String, ModInfo> _map;

  ModInfos({Map<String, ModInfo>? map}) {
    if (map != null) {
      _map = map;
    } else {
      _map = _read();
    }
  }

  String _readAsString() {
    return file.existsSync() ? file.readAsStringSync() : "{}";
  }

  Map<String, ModInfo> _read() {
    Map map = json.decode(_readAsString());
    Map<String, ModInfo> ruselt = {};
    map.forEach((key, value) {
      ruselt[key] = ModInfo.fromJson(value);
    });
    return ruselt;
  }

  void add(String modID, int curseForgeID) {
    _map[modID] = ModInfo(
      curseForgeID,
      DateTime.now(),
      modID,
    );
    save();
  }

  ModInfo? getByModID(String modID) {
    _map[modID];
  }

  void save() {
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(json.encode(_map));
  }

  ModInfos needUpdates() {
    Map<String, ModInfo> ruselt = {};
    _map.forEach((key, value) {
      if (value.needUpdate) {
        ruselt[key] = value;
      }
    });
    return ModInfos(map: ruselt);
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

  bool get needUpdate => lastUpdated.isBefore(DateTime.now().subtract(Duration(days: 10)));

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
