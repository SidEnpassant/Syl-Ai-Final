import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sylai2/models/resource_model.dart';
import 'package:sylai2/models/syllabus_model.dart';
import 'package:sylai2/models/user_model.dart';
import 'package:sylai2/services/ai_service.dart';
import 'package:sylai2/services/authTokenService.dart';
import 'package:sylai2/services/web_search_service.dart';
import 'package:sylai2/services/youtube_service.dart';
// Import the auth token service

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final AuthTokenService _authTokenService = AuthTokenService();

  // Helper method to ensure authentication for each request
  Future<bool> _ensureAuthentication() async {
    //await _authTokenService.setAuthHeader(_supabaseClient);
    try {
      await _authTokenService.setAuthHeader(_supabaseClient);
      return true;
    } catch (e) {
      print('Authentication failed: $e');
      return false;
    }
  }

  // Profiles
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      await _ensureAuthentication();
      final response =
          await _supabaseClient
              .from('profiles')
              .select()
              .eq('id', userId)
              .single();

      // ignore: unnecessary_null_comparison
      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get current user ID from local storage
  Future<String?> getCurrentUserId() async {
    return await _authTokenService.getUserId();
  }

  // Future<List<String>> generateTopicsFromSyllabus(
  //   SyllabusModel syllabus,
  // ) async {
  //   try {
  //     await _ensureAuthentication();
  //     final aiService = AiService();

  //     final topics = await aiService.extractTopicsFromSyllabus(
  //       syllabus.content,
  //     );

  //     // Update the syllabus with the extracted topics
  //     final updatedSyllabus = syllabus.copyWith(topics: topics);

  //     // Save the updated syllabus back to the database
  //     await updateSyllabus(updatedSyllabus);

  //     return topics;
  //   } catch (e) {
  //     throw Exception('Failed to generate topics from syllabus: $e');
  //   }
  // }

  // Future<List<String>> generateTopicsFromSyllabus(
  //   SyllabusModel syllabus,
  // ) async {
  //   try {
  //     await _ensureAuthentication();
  //     final aiService = AiService();
  //     final webSearchService = WebSearchService(aiService);
  //     final youtubeService = YoutubeService();

  //     final topics = await aiService.extractTopicsFromSyllabus(
  //       syllabus.content,
  //     );

  //     // Update the syllabus with the extracted topics
  //     final updatedSyllabus = syllabus.copyWith(topics: topics);

  //     // Save the updated syllabus back to the database
  //     await updateSyllabus(updatedSyllabus);

  //     // Generate resources for each topic
  //     List<ResourceModel> allResources = [];
  //     for (var topic in topics) {
  //       final webResources = await webSearchService.findStudyResources(
  //         topic,
  //         syllabus.id,
  //       );
  //       final youtubeResources = await youtubeService.findVideosByTopic(
  //         topic,
  //         syllabus.id,
  //       );

  //       allResources.addAll(webResources);
  //       allResources.addAll(youtubeResources);
  //     }

  //     // Save the generated resources
  //     await saveResources(allResources);

  //     return topics;
  //   } catch (e) {
  //     throw Exception('Failed to generate topics from syllabus: $e');
  //   }
  // }

  // Future<List<String>> generateTopicsFromSyllabus(
  //   SyllabusModel syllabus,
  // ) async {
  //   try {
  //     await _ensureAuthentication();
  //     final aiService = AiService();
  //     final webSearchService = WebSearchService(aiService);
  //     final youtubeService = YoutubeService();

  //     final topics = await aiService.extractTopicsFromSyllabus(
  //       syllabus.content,
  //     );

  //     // Update the syllabus with the extracted topics
  //     final updatedSyllabus = syllabus.copyWith(topics: topics);

  //     // Save the updated syllabus back to the database
  //     await updateSyllabus(updatedSyllabus);

  //     // Generate resources for each topic
  //     List<ResourceModel> allResources = [];
  //     for (var topic in topics) {
  //       // Fallback to mock resources if API fails
  //       List<ResourceModel> webResources = await webSearchService
  //           .findStudyResources(topic, syllabus.id);

  //       if (webResources.isEmpty) {
  //         // If no web resources found, use mock generation
  //         webResources = await webSearchService.mockFindStudyResources(
  //           topic,
  //           syllabus.id,
  //         );
  //       }

  //       final youtubeResources = await youtubeService.findVideosByTopic(
  //         topic,
  //         syllabus.id,
  //       );

  //       allResources.addAll(webResources);
  //       allResources.addAll(youtubeResources);
  //     }

  //     // Save the generated resources
  //     await saveResources(allResources);

  //     return topics;
  //   } catch (e) {
  //     throw Exception('Failed to generate topics from syllabus: $e');
  //   }
  // }

  Future<List<String>> generateTopicsFromSyllabus(
    SyllabusModel syllabus,
  ) async {
    try {
      await _ensureAuthentication();
      final aiService = AiService();
      final webSearchService = WebSearchService(aiService);
      final youtubeService = YoutubeService();

      // Extract topics from syllabus
      final topics = await aiService.extractTopicsFromSyllabus(
        syllabus.content,
      );

      // Update the syllabus with the extracted topics
      final updatedSyllabus = syllabus.copyWith(topics: topics);
      await updateSyllabus(updatedSyllabus);

      // Generate resources for each topic
      List<ResourceModel> allResources = [];
      for (var topic in topics) {
        // Try web resources with fallback to mock resources
        List<ResourceModel> webResources = await webSearchService
            .findStudyResources(topic, syllabus.id);

        if (webResources.isEmpty) {
          webResources = await webSearchService.mockFindStudyResources(
            topic,
            syllabus.id,
          );
        }

        // Find YouTube videos
        final youtubeResources = await youtubeService.findVideosByTopic(
          topic,
          syllabus.id,
        );

        // Try PDF resources (you might want to add a similar service for PDFs)
        // For now, this part is a placeholder
        List<ResourceModel> pdfResources = [];
        // Add PDF resource generation logic here if you have a PDF search service

        allResources.addAll(webResources);
        allResources.addAll(youtubeResources);
        allResources.addAll(pdfResources);
      }

      // Save the generated resources
      await saveResources(allResources);

      return topics;
    } catch (e) {
      throw Exception('Failed to generate topics from syllabus: $e');
    }
  }

  Future<SyllabusModel?> getLatestSyllabus() async {
    try {
      await _ensureAuthentication();
      final userId = await getCurrentUserId();

      if (userId == null) {
        return null; // Return null if there is no logged-in user
      }

      final response =
          await _supabaseClient
              .from('syllabi')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return SyllabusModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get latest syllabus: $e');
    }
  }

  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      await _ensureAuthentication();
      // Get syllabi count
      final syllabiResponse = await _supabaseClient
          .from('syllabi')
          .select('id')
          .eq('user_id', userId);

      int syllabiCount = syllabiResponse.length;

      // Get resources count
      final resourcesResponse = await _supabaseClient
          .from('resources')
          .select('id')
          .eq('user_id', userId);

      int resourcesCount = resourcesResponse.length;

      return {'syllabi_count': syllabiCount, 'resources_count': resourcesCount};
    } catch (e) {
      throw Exception('Failed to fetch user stats: $e');
    }
  }

  // Future<List<ResourceModel>> getResourcesBySyllabusId(
  //   String syllabusId,
  // ) async {
  //   try {
  //     await _ensureAuthentication();

  //     if (syllabusId == 'default_id' || syllabusId.isEmpty) {
  //       print('Invalid syllabus ID: $syllabusId');
  //       return []; // Return empty list instead of calling the database
  //     }
  //     // Fetch data from Supabase
  //     final response = await _supabaseClient
  //         .from('resources')
  //         .select('*')
  //         .eq('syllabus_id', syllabusId);

  //     if (response.isEmpty) {
  //       return [];
  //     }

  //     return (response as List)
  //         .map((json) => ResourceModel.fromJson(json))
  //         .toList();
  //   } catch (e) {
  //     throw Exception('Failed to get resources: $e');
  //   }
  // }

  Future<List<ResourceModel>> getResourcesBySyllabusId(
    String syllabusId,
  ) async {
    try {
      await _ensureAuthentication();

      if (syllabusId == 'default_id' || syllabusId.isEmpty) {
        print('Invalid syllabus ID: $syllabusId');
        return []; // Return empty list instead of calling the database
      }

      // Add more logging to understand what's happening
      print('Fetching resources for syllabus ID: $syllabusId');

      // Fetch data from Supabase
      final response = await _supabaseClient
          .from('resources')
          .select('*')
          .eq('syllabus_id', syllabusId);

      print('Resources response: $response');

      if (response.isEmpty) {
        print('No resources found for syllabus ID: $syllabusId');
        return [];
      }

      return (response as List)
          .map((json) => ResourceModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching resources: $e');
      throw Exception('Failed to get resources: $e');
    }
  }

  Future<void> createOrUpdateUserProfile(UserModel user) async {
    try {
      await _ensureAuthentication();
      await _supabaseClient.from('profiles').upsert(user.toJson());
    } catch (e) {
      throw Exception('Failed to create or update user profile: $e');
    }
  }

  // Syllabi
  Future<List<SyllabusModel>> getUserSyllabi(String userId) async {
    try {
      await _ensureAuthentication();
      final response = await _supabaseClient
          .from('syllabi')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => SyllabusModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user syllabi: $e');
    }
  }

  Future<SyllabusModel> getSyllabus(String syllabusId) async {
    try {
      await _ensureAuthentication();
      final response =
          await _supabaseClient
              .from('syllabi')
              .select()
              .eq('id', syllabusId)
              .single();

      return SyllabusModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get syllabus: $e');
    }
  }

  Future<SyllabusModel> createSyllabus(SyllabusModel syllabus) async {
    try {
      await _ensureAuthentication();
      final response =
          await _supabaseClient
              .from('syllabi')
              .insert(syllabus.toJson())
              .select();

      return SyllabusModel.fromJson(response[0]);
    } catch (e) {
      throw Exception('Failed to create syllabus: $e');
    }
  }

  Future<SyllabusModel?> saveSyllabus({
    required String name,
    required String content,
    required String source,
  }) async {
    try {
      bool isAuthenticated = await _ensureAuthentication();
      if (!isAuthenticated) {
        throw Exception('User is not authenticated.');
      }

      final userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception("User is not authenticated.");
      }

      final response =
          await _supabaseClient
              .from('syllabi')
              .insert({
                'user_id': userId,
                'title': name,
                'content': content,
                'source': source,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      return SyllabusModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to save syllabus: $e');
    }
  }

  Future<void> updateSyllabus(SyllabusModel syllabus) async {
    try {
      await _ensureAuthentication();
      await _supabaseClient
          .from('syllabi')
          .update(syllabus.toJson())
          .eq('id', syllabus.id);
    } catch (e) {
      throw Exception('Failed to update syllabus: $e');
    }
  }

  Future<void> deleteSyllabus(String syllabusId) async {
    try {
      await _ensureAuthentication();
      // First delete associated resources
      await _supabaseClient
          .from('resources')
          .delete()
          .eq('syllabus_id', syllabusId);

      // Then delete the syllabus
      await _supabaseClient.from('syllabi').delete().eq('id', syllabusId);
    } catch (e) {
      throw Exception('Failed to delete syllabus: $e');
    }
  }

  // Resources
  Future<List<ResourceModel>> getSyllabusResources(String syllabusId) async {
    try {
      await _ensureAuthentication();
      final response = await _supabaseClient
          .from('resources')
          .select()
          .eq('syllabus_id', syllabusId);

      return (response as List)
          .map((item) => ResourceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get syllabus resources: $e');
    }
  }

  Future<void> saveResources(List<ResourceModel> resources) async {
    if (resources.isEmpty) return;

    try {
      await _ensureAuthentication();
      await _supabaseClient
          .from('resources')
          .insert(resources.map((r) => r.toJson()).toList());
    } catch (e) {
      throw Exception('Failed to save resources: $e');
    }
  }

  // Chats
  Future<void> saveChat(String message, bool isUser) async {
    try {
      await _ensureAuthentication();
      final userId = await getCurrentUserId();

      if (userId == null) {
        throw Exception("User is not authenticated.");
      }

      await _supabaseClient.from('chats').insert({
        'user_id': userId,
        'message': message,
        'is_user': isUser,
      });
    } catch (e) {
      throw Exception('Failed to save chat: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      await _ensureAuthentication();
      final userId = await getCurrentUserId();

      if (userId == null) {
        throw Exception("User is not authenticated.");
      }

      final response = await _supabaseClient
          .from('chats')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to get chat history: $e');
    }
  }

  // Storage
  Future<String> uploadPdf(String fileName, List<int> fileBytes) async {
    try {
      await _ensureAuthentication();
      final userId = await getCurrentUserId();

      if (userId == null) {
        throw Exception("User is not authenticated.");
      }

      final filePath = 'syllabi/$userId/$fileName';
      // Convert List<int> to Uint8List
      final Uint8List uint8List = Uint8List.fromList(fileBytes);

      await _supabaseClient.storage
          .from('syllabi')
          .uploadBinary(filePath, uint8List);

      return _supabaseClient.storage.from('syllabi').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }
}
