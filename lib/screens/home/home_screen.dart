import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sylai2/app_constants.dart';
import 'package:sylai2/models/syllabus_model.dart';
import 'package:sylai2/screens/home/chat_screen.dart';
import 'package:sylai2/screens/home/resources_screen.dart';
import 'package:sylai2/screens/home/upload_screen.dart';
import 'package:sylai2/screens/settings/settings_screen.dart';
import 'package:sylai2/services/auth_service.dart';
import 'package:sylai2/widgets/common/loading_indicator.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);
final bannerAdProvider = StateProvider<BannerAd?>((ref) => null);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isInitializing = true;
  late final AuthService _authService;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _authService = ref.read(authServiceProvider);
    _loadBannerAd();
    _checkUserAuth();

    _screens = [
      const ChatScreen(),
      const UploadScreen(),
      Consumer(
        builder: (context, ref, child) {
          // This ensures the ResourcesScreen has proper provider access
          return ResourcesScreen(
            // syllabus: SyllabusModel(
            //   id: 'default_id',
            //   title: 'Default Syllabus',
            //   userId: '',
            //   content: '',
            //   source: '',
            //   createdAt: DateTime.now(),
            //   updatedAt: DateTime.now(),
            //   topics: [],
            // ),
          );
        },
      ),
      const SettingsScreen(),
    ];
  }

  Future<void> _checkUserAuth() async {
    // Wait for user data to be available
    await Future.delayed(const Duration(milliseconds: 500));

    // Get current user data if not already available
    if (_authService.currentUser == null) {
      await _authService.getCurrentUser();
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    ref.read(bannerAdProvider)?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          ref.read(bannerAdProvider.notifier).state = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );

    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    final bannerAd = ref.watch(bannerAdProvider);
    final user = ref.watch(authServiceProvider).currentUser;

    // Show loading indicator only during initial initialization
    if (_isInitializing) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    // After initialization, proceed with rendering home screen
    // even if user is null (will be handled by auth state monitoring)
    return Scaffold(
      body: IndexedStack(index: selectedTab, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: bannerAd.size.width.toDouble(),
              height: bannerAd.size.height.toDouble(),
              child: AdWidget(ad: bannerAd),
            ),
          NavigationBar(
            onDestinationSelected: (index) {
              ref.read(selectedTabProvider.notifier).state = index;
            },
            selectedIndex: selectedTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.upload_file_outlined),
                selectedIcon: Icon(Icons.upload_file),
                label: 'Upload',
              ),
              NavigationDestination(
                icon: Icon(Icons.video_library_outlined),
                selectedIcon: Icon(Icons.video_library),
                label: 'Resources',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
