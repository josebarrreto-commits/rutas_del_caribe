import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class BrandHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const BrandHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.turquoise,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: const Text('RC', style: TextStyle(
            color: AppColors.navy, fontWeight: FontWeight.w900, fontSize: 19,
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
              color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 18,
            )),
            if (subtitle != null) Text(subtitle!, style: const TextStyle(
              color: AppColors.muted, fontSize: 12,
            )),
          ],
        )),
      ],
    );
  }
}
