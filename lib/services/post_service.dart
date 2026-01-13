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
    required String postType, // text | image | video | poll | article

    // 🔹 Media input (from UI)
    File? imageFile,
    File? videoFile,

    // 🔹 Poll
    List<String>? pollOptions,
    String? pollDuration,
  }) async {

    /// 1️⃣ Upload media to Cloudinary (if any)
    List<String> mediaUrls = [];

    if (imageFile != null) {
      final imageUrl = await CloudinaryService.uploadFile(imageFile);
      mediaUrls.add(imageUrl);
    }

    if (videoFile != null) {
      final videoUrl =
      await CloudinaryService.uploadFile(videoFile, isVideo: true);
      mediaUrls.add(videoUrl);
    }

    /// 2️⃣ Call backend create post API
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

        // only send if present
        if (mediaUrls.isNotEmpty) "media_urls": mediaUrls,
        if (pollOptions != null) "poll_options": pollOptions,
        if (pollDuration != null) "poll_duration": pollDuration,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception(
        "Post creation failed: ${res.statusCode} ${res.body}",
      );
    }
  }
}
