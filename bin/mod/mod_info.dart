class ModInfo {
  final int curseForgeID;
  final String modID;

  DateTime lastUpdated;

  bool get needUpdate =>
      lastUpdated.isBefore(DateTime.now().subtract(Duration(days: 10)));

  ModInfo(this.curseForgeID, this.lastUpdated, this.modID);

  factory ModInfo.fromMap(Map<String, dynamic> json) {
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
