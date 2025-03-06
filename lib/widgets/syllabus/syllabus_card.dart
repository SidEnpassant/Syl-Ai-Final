import 'package:flutter/material.dart';
import 'package:sylai2/models/syllabus_model.dart';
import 'package:sylai2/utils/theme.dart';

import 'package:timeago/timeago.dart' as timeago;

class SyllabusCard extends StatelessWidget {
  final SyllabusModel syllabus;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const SyllabusCard({
    Key? key,
    required this.syllabus,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon based on source (PDF or chat)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          syllabus.source == 'pdf'
                              ? Colors.red.withOpacity(0.8)
                              : Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      syllabus.source == 'pdf'
                          ? Icons.picture_as_pdf
                          : Icons.chat,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          syllabus.title,
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Added ${timeago.format(syllabus.createdAt)}',
                          style: TextStyle(
                            color: AppTheme.textColor.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: AppTheme.cardColor,
                                title: Text(
                                  'Delete Syllabus',
                                  style: TextStyle(color: AppTheme.textColor),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this syllabus? This action cannot be undone.',
                                  style: TextStyle(color: AppTheme.textColor),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppTheme.accentColor,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onDelete!();
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                syllabus.content,
                style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.9),
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.video_library,
                    label: 'Resources',
                    onTap: onTap,
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {
                      // Implement share functionality
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppTheme.accentColor, size: 18),
        label: Text(
          label,
          style: TextStyle(color: AppTheme.accentColor, fontSize: 14),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: BorderSide(color: AppTheme.accentColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
