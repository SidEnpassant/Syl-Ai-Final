import 'package:flutter/material.dart';
import 'package:sylai2/utils/theme.dart';

class TopicListItem extends StatelessWidget {
  final String topic;
  final int youtubeCount;
  final int pdfCount;
  final int webCount;
  final VoidCallback onTap;

  const TopicListItem({
    Key? key,
    required this.topic,
    required this.youtubeCount,
    required this.pdfCount,
    required this.webCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  topic,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildResourceCounter(
                icon: Icons.video_library,
                count: youtubeCount,
                color: Colors.red[400]!,
              ),
              const SizedBox(width: 8),
              _buildResourceCounter(
                icon: Icons.picture_as_pdf,
                count: pdfCount,
                color: Colors.blue[400]!,
              ),
              const SizedBox(width: 8),
              _buildResourceCounter(
                icon: Icons.language,
                count: webCount,
                color: Colors.green[400]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCounter({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
