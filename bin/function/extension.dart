import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';

extension CurseForgeModFileArchive on CurseForgeModFile {
  Future<Archive?> downloadToArchive() async {
    try {
      Response response = await Dio()
          .get(downloadUrl, options: Options(responseType: ResponseType.bytes));

      return ZipDecoder().decodeBytes(response.data);
    } catch (e) {
      return null;
    }
  }
}
