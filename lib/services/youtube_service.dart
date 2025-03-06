import 'package:http/http.dart' as http;
import 'package:sylai2/app_constants.dart';
import 'dart:convert';

import '../models/resource_model.dart';

class YoutubeService {
  final String _youtubeApiKey = AppConstants.youtubeApiKey;
  final String _youtubeApiUrl = 'https://www.googleapis.com/youtube/v3/search';

  // Future<List<ResourceModel>> findVideosByTopic(
  //   String topic,
  //   String syllabusId,
  // ) async {
  //   try {
  //     final query = '$topic lecture tutorial';

  //     final response = await http.get(
  //       Uri.parse(
  //         '$_youtubeApiUrl?part=snippet&maxResults=5&q=$query&type=video&key=$_youtubeApiKey',
  //       ),
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to fetch YouTube videos: ${response.body}');
  //     }

  //     final data = jsonDecode(response.body);
  //     final items = data['items'] as List;

  //     return items.map((item) {
  //       final snippet = item['snippet'];
  //       final videoId = item['id']['videoId'];

  //       return ResourceModel(
  //         id: '', // Will be assigned by Supabase
  //         syllabusId: syllabusId,
  //         topic: topic,
  //         type: 'youtube',
  //         title: snippet['title'],
  //         url: 'https://www.youtube.com/watch?v=$videoId',
  //         description: snippet['description'],
  //         createdAt: DateTime.now(),
  //       );
  //     }).toList();
  //   } catch (e) {
  //     print('YouTube API error: $e');
  //     return [];
  //   }
  // }

  Future<List<ResourceModel>> findVideosByTopic(
    String topic,
    String syllabusId,
  ) async {
    try {
      final query = '$topic lecture tutorial';

      final response = await http.get(
        Uri.parse(
          '$_youtubeApiUrl?part=snippet&maxResults=5&q=$query&type=video&key=$_youtubeApiKey',
        ),
      );

      if (response.statusCode != 200) {
        print('YouTube API returned non-200 status: ${response.body}');
        return []; // Return empty list instead of throwing
      }

      final data = jsonDecode(response.body);
      final items = data['items'] as List? ?? [];

      return items.map((item) {
        final snippet = item['snippet'];
        final videoId = item['id']['videoId'];

        return ResourceModel(
          id: '', // Will be assigned by Supabase
          syllabusId: syllabusId,
          topic: topic,
          type: 'youtube',
          title: snippet['title'] ?? 'Untitled Video',
          url: 'https://www.youtube.com/watch?v=$videoId',
          description: snippet['description'] ?? '',
          createdAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('YouTube API error: $e');
      return [];
    }
  }
}
