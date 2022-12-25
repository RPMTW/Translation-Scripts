import '../function/PathUttily.dart';
import '../function/json_storage.dart';

class ModInfos extends JsonStorage {
  ModInfos() : super(PathUttily().getModInfoFile());
}
