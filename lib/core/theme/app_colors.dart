import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background    = Color(0xFF0A0A0B);
  static const Color surface       = Color(0xFF111114);
  static const Color surfaceDeep   = Color(0xFF0D0D10);
  static const Color surfaceCard   = Color(0xFF18181D);
  static const Color inputActive   = Color(0xFF0F080A);
  static const Color inputIdle     = Color(0xFF111114);
  static const Color successBg     = Color(0xFF0A130F);
  static const Color errorBg       = Color(0xFF120608);
  static const Color vehicleCard   = Color(0xFF1A0608);

  static const Color primary       = Color(0xFFC0272D);
  static const Color primaryDark   = Color(0xFF8A1B20);
  static const Color primaryLight  = Color(0xFFFF6B6B);
  static const Color primarySubtle = Color(0x1AC0272D);
  static const Color primaryBorder = Color(0x47C0272D);

  static const Color textPrimary   = Color(0xFFF2F2F4);
  static const Color textSecondary = Color(0xFFB0B0B8);
  static const Color textTertiary  = Color(0xFF5E5E6A);
  static const Color textDisabled  = Color(0xFF3A3A46);
  static const Color textGhost     = Color(0xFF1E1E24);

  static const Color critical      = Color(0xFFC0272D);
  static const Color moderate      = Color(0xFFE59A12);
  static const Color advisory      = Color(0xFF2DB356);

  static const Color criticalBg    = Color(0x1AC0272D);
  static const Color moderateBg    = Color(0x1AE59A12);
  static const Color advisoryBg    = Color(0x1A2DB356);
  static const Color criticalBorder= Color(0x47C0272D);
  static const Color moderateBorder= Color(0x33E59A12);
  static const Color advisoryBorder= Color(0x262DB356);

  static const Color success       = Color(0xFF2DB356);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningDark  = Color(0xFFB45309);
  static const Color successDark   = Color(0xFF1A7040);
  static const Color whatsApp      = Color(0xFF25D366);
  static const Color bluetooth     = Color(0xFF1E90FF);
  static const Color mapBgStart    = Color(0xFF0D1520);
  static const Color mapBgEnd      = Color(0xFF111A28);
  static const Color gold          = Color(0xFFE59A12);

  static const Color border        = Color(0xFF2A2A32);
  static const Color borderSubtle  = Color(0xFF1E1E24);
  static const Color borderGhost   = Color(0xFF16161C);
  static const Color navBg         = Color(0xFF111114);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryDark],
  );
}

