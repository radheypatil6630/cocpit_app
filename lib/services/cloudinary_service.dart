import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  static final _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

  static Future<String> uploadFile(File file, {bool isVideo = false}) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$_cloudName/${isVideo ? 'video' : 'image'}/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Cloudinary upload failed");
    }

    return jsonDecode(resBody)['secure_url'];
  }
}
