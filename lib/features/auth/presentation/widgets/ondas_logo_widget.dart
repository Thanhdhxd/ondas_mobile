import 'package:flutter/material.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/core/theme/app_spacing.dart';
import 'package:ondas_mobile/core/theme/app_typography.dart';

/// Ondas brand logo — waveform icon + app name.
/// Used on Login and Register screens.
class OndasLogoWidget extends StatelessWidget {
  const OndasLogoWidget({super.key, this.subtitle});

  /// Optional subtitle shown below the app name (e.g. "Đăng nhập vào Ondas").
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _WaveformIcon(size: 64, color: AppColors.spotifyGreen),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ondas',
          style: AppTypography.sectionTitle.copyWith(
            color: AppColors.spotifyGreen,
            letterSpacing: 2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: AppTypography.featureHeading.copyWith(
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ── Waveform icon ─────────────────────────────────────────────────────────────

class _WaveformIcon extends StatelessWidget {
  const _WaveformIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _WaveformPainter(color: color)),
    );
  }
}

/// Draws a sound-wave bar chart matching the Ondas logo, with 11 rounded
/// vertical bars of varying heights.
class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.color});

  final Color color;

  // Relative bar heights (0.0–1.0). Pattern mirrors the provided logo image.
  static const List<double> _heights = [
    0.38, 0.70, 0.50, 0.90, 0.22,
    0.58, 1.00, 0.28, 0.82, 0.48, 0.18,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final n = _heights.length;
    const gapRatio = 0.55;
    final slotWidth = size.width / (n + (n - 1) * gapRatio);
    final barWidth = slotWidth;
    final gap = slotWidth * gapRatio;
    final radius = Radius.circular(barWidth / 2);

    for (var i = 0; i < n; i++) {
      final barHeight = size.height * _heights[i];
      final left = i * (barWidth + gap);
      final top = (size.height - barHeight) / 2;
      final rect = RRect.fromLTRBR(
        left, top, left + barWidth, top + barHeight, radius,
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.color != color;
}
