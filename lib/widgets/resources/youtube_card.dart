import 'package:flutter/material.dart';
import 'package:sylai2/models/resource_model.dart';
import 'package:sylai2/utils/theme.dart';

import 'package:url_launcher/url_launcher.dart';

class YoutubeCard extends StatelessWidget {
  final ResourceModel resource;

  const YoutubeCard({Key? key, required this.resource}) : super(key: key);

  Future<void> _launchURL() async {
    final url = Uri.parse(resource.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _launchURL,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YouTube thumbnail with play button overlay
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Get YouTube thumbnail from video ID
                  Image.network(
                    _getYoutubeThumbnail(resource.url),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 50,
                        ),
                      );
                    },
                  ),
                  // Play button overlay
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.topic,
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resource.title,
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (resource.description != null &&
                      resource.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        resource.description!,
                        style: TextStyle(
                          color: AppTheme.textColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getYoutubeThumbnail(String url) {
    // Extract video ID from YouTube URL
    RegExp regExp = RegExp(
      r"^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*",
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    final videoId = match?.group(2);

    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/0.jpg';
    }

    return 'https://via.placeholder.com/640x360.png?text=YouTube+Video';
  }
}
