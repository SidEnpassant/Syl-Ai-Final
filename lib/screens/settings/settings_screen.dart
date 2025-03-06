import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sylai2/app_constants.dart';
import 'package:sylai2/screens/home/resources_screen.dart';
import 'package:sylai2/services/auth_service.dart';
import 'package:sylai2/services/supabase_service.dart';
import 'package:sylai2/utils/theme.dart';
import 'package:sylai2/widgets/common/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  int _processedSyllabi = 0;
  int _totalResources = 0;
  BannerAd? _bannerAd;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    //_loadUserStatsInitial(); this is removed from here
    _loadBannerAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add it here instead
    _loadUserStatsInitial();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  // Initial load from initState - doesn't show snackbars
  Future<void> _loadUserStatsInitial() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final container = ProviderScope.containerOf(context);
      final supabaseService = container.read(supabaseServiceProvider);

      // Get user ID (assuming you're storing it)
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final stats = await supabaseService.getUserStats(userId);

      if (mounted) {
        setState(() {
          _processedSyllabi = stats['syllabi_count'] ?? 0;
          _totalResources = stats['resources_count'] ?? 0;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // Can be called from a refresh button or other UI interaction - safe to show snackbars
  Future<void> _loadUserStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final container = ProviderScope.containerOf(context);
      final supabaseService = container.read(supabaseServiceProvider);

      // Get user ID (assuming you're storing it)
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final stats = await supabaseService.getUserStats(userId);

      setState(() {
        _processedSyllabi = stats['syllabi_count'] ?? 0;
        _totalResources = stats['resources_count'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user stats: ${e.toString()}')),
      );
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final container = ProviderScope.containerOf(context);
      final authService = container.read(authServiceProvider);

      await authService.signOut();

      // Navigate back to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we have an error message from initial load, show it now
    if (_errorMessage != null) {
      // Post a frame callback to show the snackbar after the build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user stats: $_errorMessage')),
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
        title: Text('Settings', style: TextStyle(color: AppTheme.textColor)),
        actions: [
          // Add a refresh button in the app bar
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.textColor),
            onPressed: _loadUserStats,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.accentColor),
              )
              : Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // User Stats Section
                      _buildStatsSection(),

                      const SizedBox(height: 24),

                      // App Settings Section
                      _buildSettingsSection(),

                      const SizedBox(height: 24),

                      // Account Section
                      _buildAccountSection(),

                      // Extra space for ad
                      const SizedBox(height: 60),
                    ],
                  ),

                  // Banner Ad at bottom
                  if (_bannerAd != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        alignment: Alignment.center,
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      elevation: 4,
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Stats',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.book,
                    title: 'Syllabi',
                    value: _processedSyllabi.toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.video_library,
                    title: 'Resources',
                    value: _totalResources.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 36),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: AppTheme.textColor, fontSize: 14)),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 4,
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Settings',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              icon: Icons.notifications,
              title: 'Notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const Divider(height: 1, thickness: 1),
            _buildSwitchTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                  // In a real app, you would apply theme changes here
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      elevation: 4,
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                  applicationIcon: Image.asset(
                    'assets/app_icon.png',
                    width: 50,
                    height: 50,
                  ),
                  children: [
                    Text(
                      'An AI-powered app that helps students find the best learning resources based on their syllabus.',
                      style: TextStyle(color: AppTheme.textColor),
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 1, thickness: 1),
            _buildActionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () async {
                final Uri url = Uri.parse('https://example.com/privacy-policy');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint('Could not launch $url');
                }
              },
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),
            Center(
              child: CustomButton(
                text: 'Sign Out',
                onPressed: _signOut,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                isLoading: _isLoading,
                width: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: AppTheme.textColor, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: AppTheme.textColor, fontSize: 16),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.textColor, size: 16),
          ],
        ),
      ),
    );
  }
}
