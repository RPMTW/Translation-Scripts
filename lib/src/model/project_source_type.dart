import 'package:hive/hive.dart';
part 'project_source_type.g.dart';

@HiveType(typeId: 3)
enum ProjectSourceType {
  @HiveField(0)
  curseforge,
  @HiveField(1)
  modrinth,
  @HiveField(2)
  github
}
