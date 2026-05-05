import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/citizen_report_model.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class CitizenReportCard extends StatelessWidget {
  final CitizenReportModel report;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const CitizenReportCard({
    Key? key,
    required this.report,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: User Info and Status
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: report.user_profile,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundImage: imageProvider,
                    radius: 20,
                  ),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.user_name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        report.created_at,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(report.status), width: 1),
                  ),
                  child: Text(
                    report.status,
                    style: TextStyle(
                      color: _getStatusColor(report.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Report Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
            child: CachedNetworkImage(
              imageUrl: report.report_image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
            ),
          ),

          // Title and Description
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  report.description,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
               /* const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      report.location,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),*/

          const Divider(height: 1),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: report.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${report.likesCount}',
                  color: report.isLiked ? Colors.red : Colors.grey[600]!,
                  onTap: onLike,
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${report.commentsCount}',
                  color: Colors.grey[600]!,
                  onTap: onComment,
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'مشاركة',
                  color: Colors.grey[600]!,
                  onTap: onShare,
                ),
                _ActionButton(
                  icon: Icons.visibility_outlined,
                  label: '${report.viewsCount}',
                  color: Colors.grey[600]!,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // تعديل الرد بحيث تظهر صورة بعد معالجة البلاغ 
          if (report.imageAfterProcessing != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : AppTheme.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply, 
                        size: 16, 
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppTheme.primaryGreen 
                            : AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'رد الصندوق:',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                   'تمت معالجة هذا البلاغ بنجاح',
                    style: TextStyle(
                      fontSize: 12, 
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.black87 
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                  imageUrl: report.imageAfterProcessing!, // رابط الصورة من المودل
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // تظهر ايقونة اذا الصورة خربانة 
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                
            ),
          ),
        

                ],
              ),
            ),
        ],
      ),
    ),]),);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'تم الإنجاز':
        return Colors.green;
      case 'قيد المعالجة':
        return Colors.orange;
      case 'جديد':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
