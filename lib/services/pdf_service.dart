import 'dart:io';

import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;
import '../services/ai_service.dart';

class PdfService {
  final AiService _aiService;

  // Fixed constructor - removed required pdfController or made it optional
  PdfService(this._aiService);

  Future<String> extractSyllabusFromPdf(File file) async {
    try {
      PDFDoc doc = await PDFDoc.fromFile(file);
      String text = await doc.text;

      // Use AI to extract only syllabus content from the PDF text
      final extractedSyllabus = await _aiService.extractSyllabusContent(text);
      return extractedSyllabus;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  Future<String> extractSyllabusFromUrl(String url) async {
    try {
      // Download the PDF
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF');
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp.pdf');
      await tempFile.writeAsBytes(response.bodyBytes);

      // Extract text
      return await extractSyllabusFromPdf(tempFile);
    } catch (e) {
      throw Exception('Failed to process PDF from URL: $e');
    }
  }
}
