import 'dart:convert';
import 'dart:io';

import '../models/story_model.dart';
import 'api_client.dart';
import 'cloudinary_service.dart';

class StoryService {
  /// Get stories grouped by author
  static Future<List<StoryGroup>> getGroupedStories() async {
    final response = await ApiClient.get("/stories/grouped");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => StoryGroup.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load stories");
    }
  }

  /// Create a new story
  static Future<void> createStory({
    required File file,
    String? title,
    String? description,
  }) async {
    // Determine if video based on extension, but CloudinaryService handles it if we pass isVideo flag.
    // We can infer from file path extension.
    final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
        file.path.toLowerCase().endsWith('.mov') ||
        file.path.toLowerCase().endsWith('.webm');

    // 1. Upload to Cloudinary
    final mediaUrl = await CloudinaryService.uploadFile(file, isVideo: isVideo);

    // 2. Create Story in Backend
    final response = await ApiClient.post(
      "/stories",
      body: {
        "title": title ?? "",
        "description": description ?? "",
        "media_url": mediaUrl,
      },
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create story");
    }
  }

  /// Delete a story
  static Future<void> deleteStory(String storyId) async {
    final response = await ApiClient.delete("/stories/$storyId");
    if (response.statusCode != 200) {
      throw Exception("Failed to delete story");
    }
  }

  /// Mark story as viewed
  static Future<void> viewStory(String storyId) async {
    final response = await ApiClient.post("/stories/$storyId/view");
    // 200 OK
    if (response.statusCode != 200) {
       // Just log, don't throw blocking error for analytics
       print("Failed to record view for story $storyId");
    }
  }

  /// React to story (Like/Unlike)
  /// reaction: currently 'true' for like, can be expanded.
  /// Returns true if liked, false if unliked (based on toggle logic in backend)
  static Future<bool> reactToStory(String storyId, String reaction) async {
    final response = await ApiClient.post(
      "/stories/$storyId/react",
      body: {"reaction": reaction},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['is_liked'] == true;
    } else {
      throw Exception("Failed to react to story");
    }
  }

  /// Get details (viewers) for a story (Author only)
  static Future<List<StoryViewerInfo>> getStoryDetails(String storyId) async {
    final response = await ApiClient.get("/stories/$storyId");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List viewers = data['viewers'] ?? [];
      return viewers.map((e) => StoryViewerInfo.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load story details");
    }
  }
}
