import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  static Future<bool> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String originalFileName,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl/upload");

      var request = http.MultipartRequest("POST", uri);

      request.fields['fileName'] = fileName;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: originalFileName,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Upload failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}