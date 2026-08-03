import 'package:flutter/material.dart';

/// Marca reutilizável; a logo horizontal é usada somente em superfícies largas.
class AppBrand extends StatelessWidget {
  final double height;
  final bool showSubtitle;

  const AppBrand({super.key, this.height = 56, this.showSubtitle = false});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/gymtrack_wordmark.png',
        height: height,
        fit: BoxFit.contain,
        semanticLabel: 'GymTrack',
      ),
      if (showSubtitle) ...[
        const SizedBox(height: 8),
        Text(
          'Seu treino. Seu ritmo.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ],
  );
}
