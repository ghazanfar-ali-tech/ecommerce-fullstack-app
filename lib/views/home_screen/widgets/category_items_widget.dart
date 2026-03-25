import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:flutter/material.dart';
Widget buildCategoryItemFromFirestore(
    BuildContext context, String imageUrl, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryContainer(context),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.image_outlined,
                      color: AppColors.iconDefault(context),
                      size: 24),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.surfaceVariant(context),
                      child: Center(
                        child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Icon(Icons.image_outlined,
                  color: AppColors.iconDefault(context), size: 24),
        ),
      ),
      const SizedBox(height: 6),
      SizedBox(
        width: 70,
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.infoLight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: AppColors.shadow(context),
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}