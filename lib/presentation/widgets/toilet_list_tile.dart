import 'package:flutter/material.dart';
import 'package:bol_il_bwa/domain/entities/toilet.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';

class ToiletListTile extends StatelessWidget {
  final Toilet toilet;
  final double? distance;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorited;

  const ToiletListTile({
    Key? key,
    required this.toilet,
    this.distance,
    required this.onTap,
    this.onFavoriteTap,
    this.isFavorited = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLocked = toilet.isLocked;
    final accentColor = isLocked ? AppTheme.lockedColor : AppTheme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 왼쪽 색상 바
                Container(
                  width: 5,
                  height: 72,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                // 아이콘
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : Icons.wc_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                ),
                // 정보
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toilet.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          toilet.address,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            if (toilet.avgRating > 0) ...[
                              const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFB8C00)),
                              const SizedBox(width: 2),
                              Text(
                                toilet.avgRating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondaryColor),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (distance != null)
                              Text(
                                '${distance!.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (isLocked) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.lockedColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '비번 필요',
                                  style: TextStyle(fontSize: 10, color: AppTheme.lockedColor, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 즐겨찾기
                IconButton(
                  onPressed: onFavoriteTap,
                  icon: Icon(
                    isFavorited ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isFavorited ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
