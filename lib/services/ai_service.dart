import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sylai2/app_constants.dart';

class AiService {
  final String _groqApiKey = AppConstants.groqApiKey;
  final String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> makeGroqRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant', // Using Llama 3 model via Groq
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get AI response: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } catch (e) {
      throw Exception('AI service error: $e');
    }
  }

  // Add this method to the AiService class
  Future<String> generateResponse(
    String message, {
    String? syllabusContent,
  }) async {
    final prompt =
        syllabusContent != null
            ? '''
        As an AI assistant for educational content, respond to the following user query about a syllabus.
        
        Syllabus Content:
        $syllabusContent
        
        User Query:
        $message
        
        Provide a helpful, concise response.
        '''
            : message;

    return await makeGroqRequest(prompt);
  }

  // Add this method to the AiService class
  Future<String?> extractSyllabusFromText(String text) async {
    final prompt = '''
    The following is text that may contain a syllabus. Please identify and extract only the syllabus content from this text. 
    A syllabus typically includes course topics, chapters, or learning objectives in a structured format.
    Return only the extracted syllabus content, formatted as a clean list of topics.
    
    Text:
    $text
  ''';

    try {
      return await makeGroqRequest(prompt);
    } catch (e) {
      print('Error extracting syllabus: $e');
      return null;
    }
  }

  Future<String> extractSyllabusContent(String pdfText) async {
    final prompt = '''
      The following is text extracted from a PDF document. Please identify and extract only the syllabus content from this text. 
      A syllabus typically includes course topics, chapters, or learning objectives in a structured format.
      Return only the extracted syllabus content, formatted as a clean list of topics.
      
      PDF Content:
      $pdfText
    ''';

    return await makeGroqRequest(prompt);
  }

  Future<List<String>> extractTopicsFromSyllabus(String syllabusContent) async {
    final prompt = '''
      From the following syllabus content, extract a list of distinct, specific topics that could be searched for educational resources.
      Format the response as a JSON array of strings.
      
      Syllabus Content:
      $syllabusContent
    ''';

    final response = await makeGroqRequest(prompt);
    try {
      final List<dynamic> topics = jsonDecode(response);
      return topics.cast<String>();
    } catch (e) {
      // Fallback if JSON parsing fails
      return syllabusContent
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    }
  }

  Future<String> chatWithAI(
    String userMessage,
    List<Map<String, dynamic>> chatHistory,
  ) async {
    // Format chat history
    final formattedHistory =
        chatHistory.map((msg) {
          return {
            'role': msg['is_user'] ? 'user' : 'assistant',
            'content': msg['message'],
          };
        }).toList();

    // Add the new user message
    formattedHistory.add({'role': 'user', 'content': userMessage});

    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama3-70b-8192',
          'messages': formattedHistory,
          'temperature': 0.7,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get AI response: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } catch (e) {
      throw Exception('AI service error: $e');
    }
  }
}
