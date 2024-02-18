import 'dart:convert';
import 'dart:io';

class ZipUtils {
  static Map<String, dynamic> unzipJson(String base64Json) {
    final decodeBase64Json = base64.decode(base64Json);
    final decodegZipJson = gzip.decode(decodeBase64Json);
    final jsonStr = utf8.decode(decodegZipJson);
    return json.decode(jsonStr) as Map<String, dynamic>;
  }

  static String zipJson(Map<String, dynamic> jsonData) {
    final jsonStr = json.encode(jsonData);
    final enCodedJson = utf8.encode(jsonStr);
    final gZipJson = gzip.encode(enCodedJson);
    return base64.encode(gZipJson);
  }

  static int jsonSizeInBytes(Map<String, dynamic> json) {
    final bytes = utf8.encode(json.toString());
    return bytes.length;
  }
}
