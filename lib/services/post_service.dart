import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'cloudinary_service.dart';

class PostService {
  static Future<void> createPost({
    required String token,
    required String content,
    required String category,
    required String postType,
    File? imageFile,
    File? videoFile,
  }) async {
    List<String> mediaUrls = [];

    if (imageFile != null) {
      mediaUrls.add(await CloudinaryService.uploadFile(imageFile));
    }

    if (videoFile != null) {
      mediaUrls.add(
        await CloudinaryService.uploadFile(videoFile, isVideo: true),
      );
    }

    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/post"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "content": content,
        "category": category,
        "post_type": postType,
        if (mediaUrls.isNotEmpty) "media_urls": mediaUrls,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception("Post failed: ${res.body}");
    }
  }
}
