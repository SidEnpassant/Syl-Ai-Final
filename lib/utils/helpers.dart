import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../utils/theme.dart';

class AppHelpers {
  // Format date for display
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format time for display
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  // Generate a random color with specific opacity
  static Color getRandomColor({double opacity = 1.0}) {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      opacity,
    );
  }

  // Extract topic keywords from syllabus content
  static List<String> extractTopicsFromSyllabus(String syllabusContent) {
    // This is a simplified implementation
    // In a real app, you might use a more sophisticated approach with AI

    final topicIndicators = [
      'Unit',
      'Module',
      'Chapter',
      'Topic',
      'Section',
      'Part',
    ];

    final lines = syllabusContent.split('\n');
    final topics = <String>[];

    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      for (var indicator in topicIndicators) {
        if (trimmedLine.startsWith('$indicator ') ||
            trimmedLine.startsWith('$indicator: ') ||
            trimmedLine.startsWith('$indicator - ')) {
          topics.add(trimmedLine);
          break;
        }
      }

      // Also look for numbered topics
      final numberPattern = RegExp(r'^\d+\.(\d+\.?)?\s+\w+');
      if (numberPattern.hasMatch(trimmedLine) && trimmedLine.length < 100) {
        topics.add(trimmedLine);
      }
    }

    return topics;
  }

  // Show a custom snackbar
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number format
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone);
  }

  // Generate a list of placeholder resources for testing
  static List<Map<String, dynamic>> generatePlaceholderResources(String topic) {
    final random = Random();
    final resources = <Map<String, dynamic>>[];

    // Generate YouTube videos
    for (var i = 0; i < random.nextInt(3) + 1; i++) {
      resources.add({
        'type': 'youtube',
        'title': 'Learn about $topic - YouTube Tutorial ${i + 1}',
        'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'description':
            'A comprehensive video tutorial about $topic with examples.',
      });
    }

    // Generate PDF books
    for (var i = 0; i < random.nextInt(2) + 1; i++) {
      resources.add({
        'type': 'pdf',
        'title': 'Complete Guide to $topic - PDF Book',
        'url': 'https://example.com/pdf/book$i.pdf',
        'description':
            'A detailed book covering all aspects of $topic for students.',
      });
    }

    // Generate Web resources
    for (var i = 0; i < random.nextInt(3) + 1; i++) {
      resources.add({
        'type': 'web',
        'title': '$topic Explained - Web Tutorial',
        'url': 'https://example.com/tutorial/$topic',
        'description':
            'An interactive web tutorial for understanding $topic concepts.',
      });
    }

    return resources;
  }
}
