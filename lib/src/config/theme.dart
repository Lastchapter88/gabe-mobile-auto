import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // =========================================================
  // 1️⃣ BRAND LAYER (Can change per client)
  // =========================================================

  static const Color brandPrimary = Color(0xFF1E3A8A);
  static const Color brandPrimaryDark = Color(0xFF0F172A);
  static const Color brandPrimaryLight = Color(0xFFEFF6FF);

  // =========================================================
  // 2️⃣ SEMANTIC STATUS LAYER (Meaning-based colors)
  // =========================================================

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // =========================================================
  // 3️⃣ STATUS SURFACE COLORS (Background variants)
  // =========================================================

  static const Color surfaceSuccess = Color(0xFFECFDF5);
  static const Color surfaceWarning = Color(0xFFFFFBEB);
  static const Color surfaceError = Color(0xFFFEF2F2);
  static const Color surfaceInfo = Color(0xFFEFF6FF);

  // =========================================================
  // 4️⃣ STRUCTURAL UI LAYER (App skeleton colors)
  // =========================================================

  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color inputBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  // =========================================================
  // 5️⃣ TEXT SYSTEM
  // =========================================================

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // =========================================================
  // 6️⃣ WORKFLOW STATUS MAPPING (Business Logic Layer)
  // =========================================================

  static const Color statusBookedBg = surfaceInfo;
  static const Color statusBookedText = brandPrimary;

  static const Color statusWorkingBg = surfaceWarning;
  static const Color statusWorkingText = warning;

  static const Color statusReadyBg = surfaceSuccess;
  static const Color statusReadyText = success;

  static const Color statusCompletedBg = Color(0xFFF1F5F9);
  static const Color statusCompletedText = textSecondary;

  static const Color statusQuoted = Color(0xFFF97316);

  static const Color paymentPendingBg = Color(0xFFFEF3C7);

  // =========================================================
  // 🔄 BACKWARD COMPATIBILITY (Aliases)
  // =========================================================
  static const Color primaryBlue = brandPrimary;
  static const Color primaryBlueDark = brandPrimaryDark;
  static const Color primaryLight = brandPrimaryLight;

  static const Color statusBooked = statusBookedBg;
  static const Color statusWorking = statusWorkingBg;
  static const Color statusReady = statusReadyBg;
  static const Color statusCompleted = statusCompletedBg;

  static const Color statusPending = statusBookedText;
  static const Color statusInProgress = statusWorkingText;
  static const Color paymentPending = paymentPendingBg;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double rounded = 99.0;
}

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get h4 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get kpiValue => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  static TextStyle get kpiLabel => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.textSecondary,
        surface: AppColors.cardBg,
        background: AppColors.scaffoldBg,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: AppColors.border)),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        labelStyle: AppTextStyles.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          textStyle: AppTextStyles.button,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.textPrimary,
          ),
          backgroundColor: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme =>
      lightTheme; // No dark mode for corporate tool yet
}
