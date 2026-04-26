import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // Spotify uses a custom font; fallback to sans-serif
  static const String fontFamily = 'SpotifyMixUI';

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const TextStyle featureHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.30,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonUppercase = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.14,
  );

  static const TextStyle navLinkBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle navLink = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.52,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle smallBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.50,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle micro = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );
}
