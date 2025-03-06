import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sylai2/app_constants.dart';
import 'package:sylai2/models/resource_model.dart';
import 'package:sylai2/services/ai_service.dart';

class WebSearchService {
  final String _serpApiKey = AppConstants.googleSearchApiKey;
  final String _serpApiUrl = 'https://serpapi.com/search';
  final AiService _aiService;

  WebSearchService(this._aiService);

  Future<List<ResourceModel>> findStudyResources(
    String topic,
    String syllabusId,
  ) async {
    final List<ResourceModel> resources = [];

    try {
      // Search for PDF study materials
      final pdfResources = await _searchPdfs(topic, syllabusId);
      resources.addAll(pdfResources);

      // Search for web resources
      final webResources = await _searchWebResources(topic, syllabusId);
      resources.addAll(webResources);

      return resources;
    } catch (e) {
      print('Web search error: $e');
      return [];
    }
  }

  Future<List<ResourceModel>> _searchPdfs(
    String topic,
    String syllabusId,
  ) async {
    try {
      final query = Uri.encodeComponent('$topic study material filetype:pdf');

      final response = await http.get(
        Uri.parse('$_serpApiUrl?q=$query&api_key=$_serpApiKey'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch PDF resources: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final organicResults = data['organic_results'] as List? ?? [];

      return organicResults
          .where((result) {
            final link = result['link'] as String? ?? '';
            return link.endsWith('.pdf');
          })
          .take(3)
          .map((result) {
            return ResourceModel(
              id: '', // Will be assigned by Supabase
              syllabusId: syllabusId,
              topic: topic,
              type: 'pdf',
              title: result['title'] ?? 'PDF Study Material',
              url: result['link'],
              description: result['snippet'],
              createdAt: DateTime.now(),
            );
          })
          .toList();
    } catch (e) {
      print('PDF search error: $e');
      return [];
    }
  }

  Future<List<ResourceModel>> _searchWebResources(
    String topic,
    String syllabusId,
  ) async {
    try {
      final query = Uri.encodeComponent(
        '$topic study guide tutorial explanation',
      );

      final response = await http.get(
        Uri.parse('$_serpApiUrl?q=$query&api_key=$_serpApiKey'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch web resources: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final organicResults = data['organic_results'] as List? ?? [];

      return organicResults.take(3).map((result) {
        return ResourceModel(
          id: '', // Will be assigned by Supabase
          syllabusId: syllabusId,
          topic: topic,
          type: 'web',
          title: result['title'] ?? 'Web Resource',
          url: result['link'],
          description: result['snippet'],
          createdAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Web resource search error: $e');
      return [];
    }
  }

  // Alternative implementation using AI for when API keys aren't available
  Future<List<ResourceModel>> mockFindStudyResources(
    String topic,
    String syllabusId,
  ) async {
    try {
      // Use AI to generate mock study resources
      final prompt = '''
        Generate a JSON array of 5 study resources for the topic: "$topic".
        Each resource should have:
        1. "type": Either "pdf" or "web"
        2. "title": A realistic title for the resource
        3. "url": A plausible URL (doesn't need to be real)
        4. "description": A brief description of the content
        Format as valid JSON only.
      ''';

      final response = await _aiService.makeGroqRequest(prompt);

      try {
        final List<dynamic> mockResources = jsonDecode(response);
        return mockResources.map((resource) {
          return ResourceModel(
            id: '', // Will be assigned by Supabase
            syllabusId: syllabusId,
            topic: topic,
            type: resource['type'],
            title: resource['title'],
            url: resource['url'],
            description: resource['description'],
            createdAt: DateTime.now(),
          );
        }).toList();
      } catch (e) {
        // Fallback if JSON parsing fails
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
