import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sylai2/models/resource_model.dart';
import 'package:sylai2/models/syllabus_model.dart';
import 'package:sylai2/services/supabase_service.dart';
import 'package:sylai2/utils/theme.dart';
import 'package:sylai2/widgets/resources/study_material_card.dart';
import 'package:sylai2/widgets/resources/youtube_card.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class ResourcesScreen extends ConsumerStatefulWidget {
  final SyllabusModel? syllabus;

  const ResourcesScreen({Key? key, this.syllabus}) : super(key: key);

  @override
  // _ResourcesScreenState createState() => _ResourcesScreenState();
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ResourceModel> _youtubeResources = [];
  List<ResourceModel> _pdfResources = [];
  List<ResourceModel> _webResources = [];
  String? _errorMessage;
  SyllabusModel? _currentSyllabus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // We call loadResources but don't show error yet
    print('Syllabus ID: ${widget.syllabus?.id ?? 'No ID'}');
    print('Syllabus Title: ${widget.syllabus?.title ?? 'No Title'}');
    _loadResourcesInitial();
    _initializeSyllabus();
  }

  Future<void> _initializeSyllabus() async {
    try {
      // Check if the passed syllabus is valid or a default placeholder
      if (widget.syllabus == null ||
          widget.syllabus!.id.isEmpty ||
          widget.syllabus!.id == 'default_id') {
        // Fetch the latest syllabus
        final supabaseService = ref.read(supabaseServiceProvider);
        final latestSyllabus = await supabaseService.getLatestSyllabus();

        if (latestSyllabus != null) {
          // Use the latest syllabus
          setState(() {
            _currentSyllabus = latestSyllabus;
          });

          // Load resources for the latest syllabus
          await _loadResources();
        } else {
          // No syllabus found
          setState(() {
            _isLoading = false;
            _errorMessage =
                "No syllabus found. Please create a syllabus first.";
          });
        }
      } else {
        // Use the passed syllabus
        setState(() {
          _currentSyllabus = widget.syllabus;
        });

        // Load resources for the passed syllabus
        await _loadResources();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing syllabus: ${e.toString()}';
      });
    }
  }

  Future<void> _loadResources() async {
    if (_currentSyllabus == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);

      final resources = await supabaseService.getResourcesBySyllabusId(
        _currentSyllabus!.id,
      );

      setState(() {
        _youtubeResources =
            resources.where((r) => r.type == 'youtube').toList();
        _pdfResources = resources.where((r) => r.type == 'pdf').toList();
        _webResources = resources.where((r) => r.type == 'web').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load resources: ${e.toString()}')),
      );
    }
  }

  // Future<void> _loadResourcesInitial() async {
  //   try {
  //     // More comprehensive syllabus ID validation
  //     if (widget.syllabus == null ||
  //         widget.syllabus!.id.isEmpty ||
  //         widget.syllabus!.id == 'default_id') {
  //       final supabaseService = ref.read(supabaseServiceProvider);

  //       // Try to fetch the latest syllabus
  //       final latestSyllabus = await supabaseService.getLatestSyllabus();

  //       if (latestSyllabus != null) {
  //         print('Using latest syllabus: ${latestSyllabus.id}');

  //         if (mounted) {
  //           setState(() {
  //             // Note: You can't directly modify widget.syllabus as it's final
  //             _currentSyllabus = latestSyllabus;
  //           });
  //         }
  //       } else {
  //         if (mounted) {
  //           setState(() {
  //             _isLoading = false;
  //             _errorMessage =
  //                 "No valid syllabus found. Please create a syllabus first.";
  //           });
  //           return;
  //         }
  //       }
  //     }

  //     final supabaseService = ref.read(supabaseServiceProvider);

  //     final resources = await supabaseService.getResourcesBySyllabusId(
  //       widget.syllabus?.id ?? '',
  //     );

  //     if (mounted) {
  //       setState(() {
  //         _youtubeResources =
  //             resources.where((r) => r.type == 'youtube').toList();
  //         _pdfResources = resources.where((r) => r.type == 'pdf').toList();
  //         _webResources = resources.where((r) => r.type == 'web').toList();
  //         _isLoading = false;
  //         _errorMessage =
  //             resources.isEmpty ? "No resources found for this syllabus" : null;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error in _loadResourcesInitial: $e');

  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //         _errorMessage = e.toString();
  //       });
  //     }
  //   }
  // }

  // Future<void> _loadResourcesInitial() async {
  //   try {
  //     print('Starting _loadResourcesInitial');
  //     print('Widget syllabus: ${widget.syllabus}');

  //     // More comprehensive syllabus ID validation
  //     if (widget.syllabus == null ||
  //         widget.syllabus!.id.isEmpty ||
  //         widget.syllabus!.id == 'default_id') {
  //       final supabaseService = ref.read(supabaseServiceProvider);

  //       // Try to fetch the latest syllabus
  //       final latestSyllabus = await supabaseService.getLatestSyllabus();

  //       if (latestSyllabus != null) {
  //         print('Using latest syllabus: ${latestSyllabus.id}');

  //         if (mounted) {
  //           setState(() {
  //             _currentSyllabus = latestSyllabus;
  //           });
  //         }
  //       } else {
  //         if (mounted) {
  //           setState(() {
  //             _isLoading = false;
  //             _errorMessage =
  //                 "No valid syllabus found. Please create a syllabus first.";
  //           });
  //           return;
  //         }
  //       }
  //     }

  //     final supabaseService = ref.read(supabaseServiceProvider);

  //     final resources = await supabaseService.getResourcesBySyllabusId(
  //       _currentSyllabus?.id ?? '', // Use the current syllabus ID
  //     );

  //     print('Loaded resources: ${resources.length}');

  //     if (mounted) {
  //       setState(() {
  //         _youtubeResources =
  //             resources.where((r) => r.type == 'youtube').toList();
  //         _pdfResources = resources.where((r) => r.type == 'pdf').toList();
  //         _webResources = resources.where((r) => r.type == 'web').toList();
  //         _isLoading = false;
  //         _errorMessage =
  //             resources.isEmpty ? "No resources found for this syllabus" : null;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error in _loadResourcesInitial: $e');

  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //         _errorMessage = e.toString();
  //       });
  //     }
  //   }
  // }

  // Future<void> _loadResourcesInitial() async {
  //   try {
  //     // More comprehensive syllabus ID validation
  //     if (widget.syllabus == null ||
  //         widget.syllabus!.id.isEmpty ||
  //         widget.syllabus!.id == 'default_id') {
  //       final supabaseService = ref.read(supabaseServiceProvider);

  //       // Try to fetch the latest syllabus
  //       final latestSyllabus = await supabaseService.getLatestSyllabus();

  //       if (latestSyllabus != null) {
  //         if (mounted) {
  //           setState(() {
  //             _currentSyllabus = latestSyllabus;
  //           });
  //         }

  //         // Generate topics and resources if none exist
  //         await supabaseService.generateTopicsFromSyllabus(latestSyllabus);
  //       } else {
  //         if (mounted) {
  //           setState(() {
  //             _isLoading = false;
  //             _errorMessage =
  //                 "No valid syllabus found. Please create a syllabus first.";
  //           });
  //           return;
  //         }
  //       }
  //     }

  //     final supabaseService = ref.read(supabaseServiceProvider);

  //     final resources = await supabaseService.getResourcesBySyllabusId(
  //       _currentSyllabus?.id ?? '',
  //     );

  //     if (resources.isEmpty) {
  //       // If no resources, try to generate
  //       if (_currentSyllabus != null) {
  //         await supabaseService.generateTopicsFromSyllabus(_currentSyllabus!);
  //       }
  //     }

  //     final updatedResources = await supabaseService.getResourcesBySyllabusId(
  //       _currentSyllabus?.id ?? '',
  //     );

  //     if (mounted) {
  //       setState(() {
  //         _youtubeResources =
  //             updatedResources.where((r) => r.type == 'youtube').toList();
  //         _pdfResources =
  //             updatedResources.where((r) => r.type == 'pdf').toList();
  //         _webResources =
  //             updatedResources.where((r) => r.type == 'web').toList();
  //         _isLoading = false;
  //         _errorMessage =
  //             updatedResources.isEmpty
  //                 ? "No resources found for this syllabus"
  //                 : null;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error in _loadResourcesInitial: $e');

  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //         _errorMessage = e.toString();
  //       });
  //     }
  //   }
  // }
  Future<void> _loadResourcesInitial() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);

      // First, try to get the latest syllabus
      final latestSyllabus = await supabaseService.getLatestSyllabus();

      if (latestSyllabus == null) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "No valid syllabus found. Please create a syllabus first.";
        });
        return;
      }

      // Set the current syllabus
      setState(() {
        _currentSyllabus = latestSyllabus;
      });

      // Try to generate topics and resources if not existing
      await supabaseService.generateTopicsFromSyllabus(latestSyllabus);

      // Fetch resources
      final resources = await supabaseService.getResourcesBySyllabusId(
        latestSyllabus.id,
      );

      if (mounted) {
        setState(() {
          _youtubeResources =
              resources.where((r) => r.type == 'youtube').toList();
          _pdfResources = resources.where((r) => r.type == 'pdf').toList();
          _webResources = resources.where((r) => r.type == 'web').toList();

          _isLoading = false;
          _errorMessage =
              resources.isEmpty
                  ? "No resources found. Ensure your syllabus contains topics."
                  : null;
        });
      }
    } catch (e) {
      print('Error in _loadResourcesInitial: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we have an error message from initial load, show it now
    if (_errorMessage != null) {
      // Post a frame callback to show the snackbar after the build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load resources: $_errorMessage')),
        );
        // Clear the error message to avoid showing multiple times
        setState(() {
          _errorMessage = null;
        });
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Resources for ${_currentSyllabus?.title}',
          style: TextStyle(color: AppTheme.textColor),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.video_library), text: "YouTube"),
            Tab(icon: Icon(Icons.picture_as_pdf), text: "PDF Books"),
            Tab(icon: Icon(Icons.web), text: "Web Resources"),
          ],
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.accentColor),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  // YouTube resources tab
                  _buildResourceList(_youtubeResources, 'youtube'),

                  // PDF resources tab
                  _buildResourceList(_pdfResources, 'pdf'),

                  // Web resources tab
                  _buildResourceList(_webResources, 'web'),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: _loadResources,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildResourceList(List<ResourceModel> resources, String type) {
    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'youtube'
                  ? Icons.video_library_outlined
                  : type == 'pdf'
                  ? Icons.picture_as_pdf_outlined
                  : Icons.web_outlined,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type == 'youtube'
                  ? 'YouTube videos'
                  : type == 'pdf'
                  ? 'PDF books'
                  : 'web resources'} found',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];

        if (type == 'youtube') {
          return YoutubeCard(resource: resource);
        } else if (type == 'pdf') {
          return StudyMaterialCard(resource: resource, isPdf: true);
        } else {
          return StudyMaterialCard(resource: resource, isPdf: false);
        }
      },
    );
  }
}
