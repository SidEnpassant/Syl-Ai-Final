import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sylai2/app_constants.dart';
import 'package:sylai2/services/pdf_service.dart';
import 'package:sylai2/services/ai_service.dart';
import 'package:sylai2/services/supabase_service.dart';
import 'package:sylai2/widgets/common/custom_button.dart';
import 'package:sylai2/widgets/common/loading_indicator.dart';

// Define providers
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  final aiService = ref.read(aiServiceProvider);
  return PdfService(aiService);
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _selectedFile;
  String _fileName = '';
  bool _isLoading = false;
  String _loadingMessage = '';
  String? _extractedText;
  String? _extractedSyllabus;
  bool _processingComplete = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    // Check authentication status when the screen loads
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Checking authentication...';
    });

    try {
      // Use Supabase directly to check authentication status
      final user = Supabase.instance.client.auth.currentUser;

      setState(() {
        _isAuthenticated = user != null;
      });

      if (!_isAuthenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to log in to save syllabi')),
        );
        // Optionally navigate to login screen
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Authentication error: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
          _extractedText = null;
          _extractedSyllabus = null;
          _processingComplete = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking PDF: $e')));
      }
    }
  }

  Future<void> _processPDF() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Extracting text from PDF...';
      _processingComplete = false;
    });

    try {
      // Extract text from PDF
      final pdfService = ref.read(pdfServiceProvider);
      // Fixed: Pass the actual File object, not a File path as File
      final extractedText = await pdfService.extractSyllabusFromPdf(
        _selectedFile!,
      );

      setState(() {
        _extractedText = extractedText;
        _loadingMessage = 'Identifying syllabus content...';
      });

      // Use AI to extract syllabus content
      final aiService = ref.read(aiServiceProvider);
      final extractedSyllabus = await aiService.extractSyllabusContent(
        extractedText,
      );

      setState(() {
        _extractedSyllabus = extractedSyllabus;
        _processingComplete = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error processing PDF: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSyllabus() async {
    if (_extractedSyllabus == null) return;

    // Check authentication before proceeding
    if (!_isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to save your syllabus')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Saving syllabus...';
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);

      // Check if user is authenticated first
      final userId = await supabaseService.getCurrentUserId();
      if (userId == null) {
        // User is not authenticated, handle this case
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed. Please log in again.'),
            ),
          );
        }
        return;
      }

      // Using the new saveSyllabus method
      final syllabusModel = await supabaseService.saveSyllabus(
        name: _fileName.replaceAll('.pdf', ''),
        content: _extractedSyllabus!,
        source: 'pdf',
      );

      setState(() {
        _loadingMessage = 'Generating topics...';
      });

      // Generate topics from syllabus - use the ID from the returned model
      if (syllabusModel != null) {
        await supabaseService.getSyllabusResources(syllabusModel.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppConstants.syllabusUploadedMessage)),
        );

        // Reset the form
        setState(() {
          _selectedFile = null;
          _fileName = '';
          _extractedText = null;
          _extractedSyllabus = null;
          _processingComplete = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving syllabus: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Syllabus'),
        actions: [
          // Add a refresh button to re-check authentication
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAuthStatus,
            tooltip: 'Refresh authentication status',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const LoadingIndicator(),
                    const SizedBox(height: 16),
                    Text(_loadingMessage),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Authentication status indicator
                    if (!_isAuthenticated)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'You are not logged in. You can process a syllabus but will not be able to save it.',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to login screen
                                // Navigator.of(context).pushNamed('/login');
                              },
                              child: const Text('LOG IN'),
                            ),
                          ],
                        ),
                      ),

                    // Instructions card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Upload Your Syllabus',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Upload a PDF file containing your course syllabus. The AI will extract the syllabus content and help you find relevant study resources.',
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Select PDF File',
                              icon: Icons.upload_file,
                              onPressed: _pickPDF,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_selectedFile != null) ...[
                      const SizedBox(height: 24),

                      // Selected file info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.description),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _fileName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _selectedFile = null;
                                        _fileName = '';
                                        _extractedText = null;
                                        _extractedSyllabus = null;
                                        _processingComplete = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (!_processingComplete) ...[
                                const SizedBox(height: 16),
                                CustomButton(
                                  text: 'Process PDF',
                                  onPressed: _processPDF,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (_extractedSyllabus != null) ...[
                      const SizedBox(height: 24),

                      // Extracted syllabus preview
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Extracted Syllabus',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: SingleChildScrollView(
                                  child: Text(_extractedSyllabus!),
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'Save Syllabus',
                                onPressed: _saveSyllabus,
                                // Disable the button if user is not authenticated
                                //isDisabled: !_isAuthenticated,
                              ),
                              if (!_isAuthenticated) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Log in to save this syllabus',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
