import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  const ModuleCard({super.key, required this.title, required this.description,
    required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.turquoise.withOpacity(0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppColors.navy, size: 25),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(
              color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15,
            )),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(
              color: AppColors.muted, fontSize: 11,
            )),
          ]),
        ),
      ),
    );
  }
}
