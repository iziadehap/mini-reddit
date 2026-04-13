// ============================================================
//  app_theme.dart
//  Reddit-style design system for Flutter
//  — ThemeExtension design tokens (RedditTokens)
//  — Full Light & Dark ThemeData
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ────────────────────────────────────────────────────────────
// 1. RAW PALETTE  (never use these directly in UI widgets –
//    always go through RedditTokens)
// ────────────────────────────────────────────────────────────
abstract final class _Palette {
  // Brand
  static const orange = Color(0xFFFF4500); // r/eddit orange
  static const orangeLight = Color(0xFFFF6534);
  static const orangeDark = Color(0xFFCC3700);
  static const blue = Color(0xFF0079D3); // upvote/link blue
  static const blueLight = Color(0xFF24A0ED);
  static const green = Color(0xFF46D160); // success / join
  static const red = Color(0xFFFF585B); // downvote / error
  static const gold = Color(0xFFFFB000); // award gold
  static const silver = Color(0xFFC0C0C0);

  // ── DARK surfaces (true dark, not pitch black)
  static const darkBg = Color(0xFF0D1117); // deepest bg
  static const darkCanvas = Color(0xFF0F1923); // feed canvas
  static const darkSurface = Color(0xFF161B22); // cards / sheets
  static const darkElevated = Color(0xFF1C2128); // dialogs / nav
  static const darkBorder = Color(0xFF30363D);
  static const darkDivider = Color(0xFF21262D);
  static const darkInputFill = Color(0xFF21262D);

  // ── LIGHT surfaces
  static const lightBg = Color(0xFFFFFFFF);
  static const lightCanvas = Color(0xFFDAE0E6); // classic Reddit grey canvas
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightElevated = Color(0xFFF6F7F8);
  static const lightBorder = Color(0xFFEDEFF1);
  static const lightDivider = Color(0xFFEDEFF1);
  static const lightInputFill = Color(0xFFF6F7F8);

  // ── Text
  static const darkTextPrimary = Color(0xFFD7DADC);
  static const darkTextSecondary = Color(0xFF818384);
  static const darkTextMuted = Color(0xFF4A4F55);
  static const lightTextPrimary = Color(0xFF1C1C1C);
  static const lightTextSecondary = Color(0xFF878A8C);
  static const lightTextMuted = Color(0xFFDADADA);

  // ── Upvote / downvote
  static const upvote = Color(0xFFFF4500);
  static const downvote = Color(0xFF7193FF);
  static const neutral = Color(0xFF818384);
}

// ────────────────────────────────────────────────────────────
// 2. SPACING & RADIUS TOKENS  (static, not theme-dependent)
// ────────────────────────────────────────────────────────────
abstract final class ppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 9999;
}

abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

// ────────────────────────────────────────────────────────────
// 3. TYPOGRAPHY TOKEN  (text styles that live in ThemeExtension)
// ────────────────────────────────────────────────────────────
class RedditTypography extends ThemeExtension<RedditTypography> {
  const RedditTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.postTitle,
    required this.postMeta,
    required this.communityName,
    required this.voteCount,
    required this.commentCount,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  // Reddit-specific semantic styles
  final TextStyle postTitle; // feed post headline
  final TextStyle postMeta; // "r/name  •  u/user  •  3h"
  final TextStyle communityName; // "r/flutter" in headers
  final TextStyle voteCount; // vote score
  final TextStyle commentCount; // "142 comments"

  @override
  RedditTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? postTitle,
    TextStyle? postMeta,
    TextStyle? communityName,
    TextStyle? voteCount,
    TextStyle? commentCount,
  }) {
    return RedditTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
      postTitle: postTitle ?? this.postTitle,
      postMeta: postMeta ?? this.postMeta,
      communityName: communityName ?? this.communityName,
      voteCount: voteCount ?? this.voteCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  @override
  RedditTypography lerp(RedditTypography? other, double t) {
    if (other == null) return this;
    return RedditTypography(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      postTitle: TextStyle.lerp(postTitle, other.postTitle, t)!,
      postMeta: TextStyle.lerp(postMeta, other.postMeta, t)!,
      communityName: TextStyle.lerp(communityName, other.communityName, t)!,
      voteCount: TextStyle.lerp(voteCount, other.voteCount, t)!,
      commentCount: TextStyle.lerp(commentCount, other.commentCount, t)!,
    );
  }
}

// ────────────────────────────────────────────────────────────
// 4. COLOR TOKEN  (the main ThemeExtension)
// ────────────────────────────────────────────────────────────
class RedditTokens extends ThemeExtension<RedditTokens> {
  const RedditTokens({
    // ── Brand
    required this.brandOrange,
    required this.brandOrangeLight,
    required this.brandOrangeDark,
    required this.brandBlue,
    required this.brandBlueMuted,
    // ── Surfaces
    required this.bgPage,
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgElevated,
    required this.bgInput,
    required this.bgOverlay,
    // ── Borders
    required this.borderDefault,
    required this.borderFocused,
    required this.divider,
    // ── Text
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.textLink,
    // ── Semantic
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    // ── Vote
    required this.upvote,
    required this.downvote,
    required this.voteNeutral,
    // ── Interactive
    required this.buttonPrimary,
    required this.buttonPrimaryText,
    required this.buttonSecondary,
    required this.buttonSecondaryText,
    required this.buttonDestructive,
    required this.buttonJoin,
    // ── Nav / chrome
    required this.navBar,
    required this.navBarBorder,
    required this.navItemSelected,
    required this.navItemUnselected,
    // ── Post card
    required this.cardBg,
    required this.cardBorder,
    required this.cardVoteBar,
    // ── Award
    required this.awardGold,
    required this.awardSilver,
    // ── Flair / tag
    required this.flairBg,
    required this.flairText,
  });

  // Brand
  final Color brandOrange;
  final Color brandOrangeLight;
  final Color brandOrangeDark;
  final Color brandBlue;
  final Color brandBlueMuted;

  // Surfaces
  final Color bgPage;
  final Color bgCanvas;
  final Color bgSurface;
  final Color bgElevated;
  final Color bgInput;
  final Color bgOverlay;

  // Borders
  final Color borderDefault;
  final Color borderFocused;
  final Color divider;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textInverse;
  final Color textLink;

  // Semantic
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  // Vote
  final Color upvote;
  final Color downvote;
  final Color voteNeutral;

  // Interactive
  final Color buttonPrimary;
  final Color buttonPrimaryText;
  final Color buttonSecondary;
  final Color buttonSecondaryText;
  final Color buttonDestructive;
  final Color buttonJoin;

  // Nav / chrome
  final Color navBar;
  final Color navBarBorder;
  final Color navItemSelected;
  final Color navItemUnselected;

  // Post card
  final Color cardBg;
  final Color cardBorder;
  final Color cardVoteBar;

  // Award
  final Color awardGold;
  final Color awardSilver;

  // Flair
  final Color flairBg;
  final Color flairText;

  // ── convenience getters ──────────────────────────────────
  bool get isDark => bgPage.computeLuminance() < 0.05;

  Color get orangeWithOpacity10 => brandOrange.withOpacity(0.10);
  Color get orangeWithOpacity20 => brandOrange.withOpacity(0.20);
  Color get errorWithOpacity15 => error.withOpacity(0.15);
  Color get successWithOpacity15 => success.withOpacity(0.15);

  // ── ThemeExtension impl ──────────────────────────────────
  @override
  RedditTokens copyWith({
    Color? brandOrange,
    Color? brandOrangeLight,
    Color? brandOrangeDark,
    Color? brandBlue,
    Color? brandBlueMuted,
    Color? bgPage,
    Color? bgCanvas,
    Color? bgSurface,
    Color? bgElevated,
    Color? bgInput,
    Color? bgOverlay,
    Color? borderDefault,
    Color? borderFocused,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textInverse,
    Color? textLink,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? upvote,
    Color? downvote,
    Color? voteNeutral,
    Color? buttonPrimary,
    Color? buttonPrimaryText,
    Color? buttonSecondary,
    Color? buttonSecondaryText,
    Color? buttonDestructive,
    Color? buttonJoin,
    Color? navBar,
    Color? navBarBorder,
    Color? navItemSelected,
    Color? navItemUnselected,
    Color? cardBg,
    Color? cardBorder,
    Color? cardVoteBar,
    Color? awardGold,
    Color? awardSilver,
    Color? flairBg,
    Color? flairText,
  }) {
    return RedditTokens(
      brandOrange: brandOrange ?? this.brandOrange,
      brandOrangeLight: brandOrangeLight ?? this.brandOrangeLight,
      brandOrangeDark: brandOrangeDark ?? this.brandOrangeDark,
      brandBlue: brandBlue ?? this.brandBlue,
      brandBlueMuted: brandBlueMuted ?? this.brandBlueMuted,
      bgPage: bgPage ?? this.bgPage,
      bgCanvas: bgCanvas ?? this.bgCanvas,
      bgSurface: bgSurface ?? this.bgSurface,
      bgElevated: bgElevated ?? this.bgElevated,
      bgInput: bgInput ?? this.bgInput,
      bgOverlay: bgOverlay ?? this.bgOverlay,
      borderDefault: borderDefault ?? this.borderDefault,
      borderFocused: borderFocused ?? this.borderFocused,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      textLink: textLink ?? this.textLink,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      upvote: upvote ?? this.upvote,
      downvote: downvote ?? this.downvote,
      voteNeutral: voteNeutral ?? this.voteNeutral,
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      buttonPrimaryText: buttonPrimaryText ?? this.buttonPrimaryText,
      buttonSecondary: buttonSecondary ?? this.buttonSecondary,
      buttonSecondaryText: buttonSecondaryText ?? this.buttonSecondaryText,
      buttonDestructive: buttonDestructive ?? this.buttonDestructive,
      buttonJoin: buttonJoin ?? this.buttonJoin,
      navBar: navBar ?? this.navBar,
      navBarBorder: navBarBorder ?? this.navBarBorder,
      navItemSelected: navItemSelected ?? this.navItemSelected,
      navItemUnselected: navItemUnselected ?? this.navItemUnselected,
      cardBg: cardBg ?? this.cardBg,
      cardBorder: cardBorder ?? this.cardBorder,
      cardVoteBar: cardVoteBar ?? this.cardVoteBar,
      awardGold: awardGold ?? this.awardGold,
      awardSilver: awardSilver ?? this.awardSilver,
      flairBg: flairBg ?? this.flairBg,
      flairText: flairText ?? this.flairText,
    );
  }

  @override
  RedditTokens lerp(RedditTokens? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return RedditTokens(
      brandOrange: l(brandOrange, other.brandOrange),
      brandOrangeLight: l(brandOrangeLight, other.brandOrangeLight),
      brandOrangeDark: l(brandOrangeDark, other.brandOrangeDark),
      brandBlue: l(brandBlue, other.brandBlue),
      brandBlueMuted: l(brandBlueMuted, other.brandBlueMuted),
      bgPage: l(bgPage, other.bgPage),
      bgCanvas: l(bgCanvas, other.bgCanvas),
      bgSurface: l(bgSurface, other.bgSurface),
      bgElevated: l(bgElevated, other.bgElevated),
      bgInput: l(bgInput, other.bgInput),
      bgOverlay: l(bgOverlay, other.bgOverlay),
      borderDefault: l(borderDefault, other.borderDefault),
      borderFocused: l(borderFocused, other.borderFocused),
      divider: l(divider, other.divider),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      textInverse: l(textInverse, other.textInverse),
      textLink: l(textLink, other.textLink),
      success: l(success, other.success),
      error: l(error, other.error),
      warning: l(warning, other.warning),
      info: l(info, other.info),
      upvote: l(upvote, other.upvote),
      downvote: l(downvote, other.downvote),
      voteNeutral: l(voteNeutral, other.voteNeutral),
      buttonPrimary: l(buttonPrimary, other.buttonPrimary),
      buttonPrimaryText: l(buttonPrimaryText, other.buttonPrimaryText),
      buttonSecondary: l(buttonSecondary, other.buttonSecondary),
      buttonSecondaryText: l(buttonSecondaryText, other.buttonSecondaryText),
      buttonDestructive: l(buttonDestructive, other.buttonDestructive),
      buttonJoin: l(buttonJoin, other.buttonJoin),
      navBar: l(navBar, other.navBar),
      navBarBorder: l(navBarBorder, other.navBarBorder),
      navItemSelected: l(navItemSelected, other.navItemSelected),
      navItemUnselected: l(navItemUnselected, other.navItemUnselected),
      cardBg: l(cardBg, other.cardBg),
      cardBorder: l(cardBorder, other.cardBorder),
      cardVoteBar: l(cardVoteBar, other.cardVoteBar),
      awardGold: l(awardGold, other.awardGold),
      awardSilver: l(awardSilver, other.awardSilver),
      flairBg: l(flairBg, other.flairBg),
      flairText: l(flairText, other.flairText),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 5. TOKEN INSTANCES
// ────────────────────────────────────────────────────────────
final _darkTokens = RedditTokens(
  // Brand
  brandOrange: _Palette.orange,
  brandOrangeLight: _Palette.orangeLight,
  brandOrangeDark: _Palette.orangeDark,
  brandBlue: _Palette.blueLight,
  brandBlueMuted: _Palette.blue.withOpacity(0.60),
  // Surfaces
  bgPage: _Palette.darkBg,
  bgCanvas: _Palette.darkCanvas,
  bgSurface: _Palette.darkSurface,
  bgElevated: _Palette.darkElevated,
  bgInput: _Palette.darkInputFill,
  bgOverlay: Colors.black.withOpacity(0.72),
  // Borders
  borderDefault: _Palette.darkBorder,
  borderFocused: _Palette.orange,
  divider: _Palette.darkDivider,
  // Text
  textPrimary: _Palette.darkTextPrimary,
  textSecondary: _Palette.darkTextSecondary,
  textMuted: _Palette.darkTextMuted,
  textInverse: _Palette.lightTextPrimary,
  textLink: _Palette.blueLight,
  // Semantic
  success: _Palette.green,
  error: _Palette.red,
  warning: _Palette.gold,
  info: _Palette.blueLight,
  // Vote
  upvote: _Palette.upvote,
  downvote: _Palette.downvote,
  voteNeutral: _Palette.neutral,
  // Interactive
  buttonPrimary: _Palette.orange,
  buttonPrimaryText: Colors.white,
  buttonSecondary: _Palette.darkElevated,
  buttonSecondaryText: _Palette.darkTextPrimary,
  buttonDestructive: _Palette.red,
  buttonJoin: _Palette.green,
  // Nav
  navBar: _Palette.darkSurface,
  navBarBorder: _Palette.darkBorder,
  navItemSelected: _Palette.orange,
  navItemUnselected: _Palette.neutral,
  // Card
  cardBg: _Palette.darkSurface,
  cardBorder: _Palette.darkBorder,
  cardVoteBar: _Palette.darkElevated,
  // Awards
  awardGold: _Palette.gold,
  awardSilver: _Palette.silver,
  // Flair
  flairBg: _Palette.orange.withOpacity(0.15),
  flairText: _Palette.orangeLight,
);

final _lightTokens = RedditTokens(
  // Brand
  brandOrange: _Palette.orange,
  brandOrangeLight: _Palette.orangeLight,
  brandOrangeDark: _Palette.orangeDark,
  brandBlue: _Palette.blue,
  brandBlueMuted: _Palette.blue.withOpacity(0.60),
  // Surfaces
  bgPage: _Palette.lightBg,
  bgCanvas: _Palette.lightCanvas,
  bgSurface: _Palette.lightSurface,
  bgElevated: _Palette.lightElevated,
  bgInput: _Palette.lightInputFill,
  bgOverlay: Colors.black.withOpacity(0.50),
  // Borders
  borderDefault: _Palette.lightBorder,
  borderFocused: _Palette.orange,
  divider: _Palette.lightDivider,
  // Text
  textPrimary: _Palette.lightTextPrimary,
  textSecondary: _Palette.lightTextSecondary,
  textMuted: _Palette.lightTextMuted,
  textInverse: _Palette.darkTextPrimary,
  textLink: _Palette.blue,
  // Semantic
  success: _Palette.green,
  error: _Palette.red,
  warning: _Palette.gold,
  info: _Palette.blue,
  // Vote
  upvote: _Palette.upvote,
  downvote: _Palette.downvote,
  voteNeutral: _Palette.neutral,
  // Interactive
  buttonPrimary: _Palette.orange,
  buttonPrimaryText: Colors.white,
  buttonSecondary: _Palette.lightElevated,
  buttonSecondaryText: _Palette.lightTextPrimary,
  buttonDestructive: _Palette.red,
  buttonJoin: _Palette.green,
  // Nav
  navBar: _Palette.lightSurface,
  navBarBorder: _Palette.lightBorder,
  navItemSelected: _Palette.orange,
  navItemUnselected: _Palette.lightTextSecondary,
  // Card
  cardBg: _Palette.lightSurface,
  cardBorder: _Palette.lightBorder,
  cardVoteBar: _Palette.lightElevated,
  // Awards
  awardGold: _Palette.gold,
  awardSilver: _Palette.silver,
  // Flair
  flairBg: _Palette.orange.withOpacity(0.10),
  flairText: _Palette.orangeDark,
);

// ────────────────────────────────────────────────────────────
// 6. TYPOGRAPHY INSTANCES
// ────────────────────────────────────────────────────────────
RedditTypography _buildTypography(Color primary, Color secondary, Color muted) {
  // IBM Plex Sans — same font Reddit actually uses in its redesign.
  // Falls back to system font if not added to pubspec.yaml.
  const fontFamily = 'IBMPlexSans';

  return RedditTypography(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: primary,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: -0.4,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: -0.3,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: primary,
      letterSpacing: -0.2,
      height: 1.35,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primary,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: primary,
      height: 1.55,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: primary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: secondary,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: secondary,
      letterSpacing: 0.2,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: muted,
      letterSpacing: 0.3,
    ),
    // Reddit-semantic
    postTitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: primary,
      height: 1.35,
      letterSpacing: -0.15,
    ),
    postMeta: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: secondary,
      height: 1.4,
    ),
    communityName: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: -0.1,
    ),
    voteCount: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: muted,
      letterSpacing: 0.2,
    ),
    commentCount: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: secondary,
    ),
  );
}

final _darkTypography = _buildTypography(
  _Palette.darkTextPrimary,
  _Palette.darkTextSecondary,
  _Palette.darkTextMuted,
);

final _lightTypography = _buildTypography(
  _Palette.lightTextPrimary,
  _Palette.lightTextSecondary,
  _Palette.lightTextMuted,
);

// ────────────────────────────────────────────────────────────
// 7. SHARED COMPONENT THEMES
// ────────────────────────────────────────────────────────────
ElevatedButtonThemeData _elevatedButtonTheme(RedditTokens t) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: t.buttonPrimary,
      foregroundColor: t.buttonPrimaryText,
      disabledBackgroundColor: t.buttonPrimary.withOpacity(0.35),
      disabledForegroundColor: t.buttonPrimaryText.withOpacity(0.50),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      textStyle: const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    ),
  );
}

OutlinedButtonThemeData _outlinedButtonTheme(RedditTokens t) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: t.brandOrange,
      side: BorderSide(color: t.brandOrange, width: 1.5),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      textStyle: const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

TextButtonThemeData _textButtonTheme(RedditTokens t) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: t.brandOrange,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: const TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

InputDecorationTheme _inputTheme(RedditTokens t) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: t.borderDefault),
  );
  return InputDecorationTheme(
    filled: true,
    fillColor: t.bgInput,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    hintStyle: TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 14,
      color: t.textSecondary,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: t.borderFocused, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: t.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: t.error, width: 1.5),
    ),
    errorStyle: TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 12,
      color: t.error,
    ),
  );
}

SnackBarThemeData _snackBarTheme(RedditTokens t) {
  return SnackBarThemeData(
    backgroundColor: t.bgElevated,
    contentTextStyle: TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 14,
      color: t.textPrimary,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
  );
}

CardThemeData _cardTheme(RedditTokens t) {
  return CardThemeData(
    color: t.cardBg,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      side: BorderSide(color: t.cardBorder, width: 0.8),
    ),
  );
}

ChipThemeData _chipTheme(RedditTokens t) {
  return ChipThemeData(
    backgroundColor: t.bgElevated,
    selectedColor: t.brandOrange.withOpacity(0.15),
    secondarySelectedColor: t.brandOrange.withOpacity(0.15),
    labelStyle: TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: t.textSecondary,
    ),
    secondaryLabelStyle: TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: t.brandOrange,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    ),
    side: BorderSide(color: t.borderDefault),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.full),
    ),
  );
}

BottomNavigationBarThemeData _bottomNavTheme(RedditTokens t) {
  return BottomNavigationBarThemeData(
    backgroundColor: t.navBar,
    selectedItemColor: t.navItemSelected,
    unselectedItemColor: t.navItemUnselected,
    selectedLabelStyle: const TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 10,
      fontWeight: FontWeight.w700,
    ),
    unselectedLabelStyle: const TextStyle(
      fontFamily: 'IBMPlexSans',
      fontSize: 10,
    ),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  );
}

NavigationBarThemeData _navigationBarTheme(RedditTokens t) {
  return NavigationBarThemeData(
    backgroundColor: t.navBar,
    indicatorColor: t.brandOrange.withOpacity(0.15),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: t.navItemSelected, size: 24);
      }
      return IconThemeData(color: t.navItemUnselected, size: 24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: t.navItemSelected,
        );
      }
      return TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 11,
        color: t.navItemUnselected,
      );
    }),
    elevation: 0,
  );
}

DividerThemeData _dividerTheme(RedditTokens t) {
  return DividerThemeData(color: t.divider, thickness: 0.8, space: 0);
}

// ────────────────────────────────────────────────────────────
// 8. AppTheme  (public API)
// ────────────────────────────────────────────────────────────
abstract final class AppTheme {
  // ── Extension access helper ──────────────────────────────
  /// Usage: `context.tokens`  or  `context.rTypo`
  static RedditTokens tokensOf(BuildContext context) =>
      Theme.of(context).extension<RedditTokens>()!;

  static RedditTypography typographyOf(BuildContext context) =>
      Theme.of(context).extension<RedditTypography>()!;

  // ── Legacy static colors (kept for backward-compat) ──────
  static const darkBackground = _Palette.darkBg;
  static const darkSurface = _Palette.darkSurface;
  static const darkElevated = _Palette.darkElevated;
  static const orange = _Palette.orange;
  static const blue = _Palette.blue;
  static const green = _Palette.green;
  static const red = _Palette.red;

  // ── Dark ThemeData ────────────────────────────────────────
  static ThemeData get dark {
    final t = _darkTokens;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: t.bgPage,
      colorScheme: ColorScheme.dark(
        primary: t.brandOrange,
        onPrimary: Colors.white,
        primaryContainer: t.brandOrange.withOpacity(0.20),
        onPrimaryContainer: t.brandOrangeLight,
        secondary: t.brandBlue,
        onSecondary: Colors.white,
        secondaryContainer: t.brandBlue.withOpacity(0.20),
        onSecondaryContainer: t.brandBlue,
        surface: t.bgSurface,
        onSurface: t.textPrimary,
        surfaceContainerHighest: t.bgElevated,
        onSurfaceVariant: t.textSecondary,
        outline: t.borderDefault,
        outlineVariant: t.divider,
        error: t.error,
        onError: Colors.white,
        errorContainer: t.error.withOpacity(0.15),
        onErrorContainer: t.error,
        inverseSurface: t.bgPage,
        onInverseSurface: t.textPrimary,
        scrim: Colors.black54,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.bgSurface,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: t.textPrimary,
        ),
        iconTheme: IconThemeData(color: t.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: t.navBar,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(t),
      outlinedButtonTheme: _outlinedButtonTheme(t),
      textButtonTheme: _textButtonTheme(t),
      inputDecorationTheme: _inputTheme(t),
      snackBarTheme: _snackBarTheme(t),
      cardTheme: _cardTheme(t),
      chipTheme: _chipTheme(t),
      bottomNavigationBarTheme: _bottomNavTheme(t),
      navigationBarTheme: _navigationBarTheme(t),
      dividerTheme: _dividerTheme(t),
      iconTheme: IconThemeData(color: t.textSecondary, size: 22),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.brandOrange),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.brandOrange
              : t.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.brandOrange.withOpacity(0.40)
              : t.bgElevated,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.brandOrange
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: t.borderDefault, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.brandOrange
              : t.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.bgSurface,
        modalBackgroundColor: t.bgSurface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.bgElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: t.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          color: t.textSecondary,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.bgElevated,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          color: t.textPrimary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: t.brandOrange,
        unselectedLabelColor: t.textSecondary,
        indicatorColor: t.brandOrange,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      extensions: [t, _darkTypography],
    );
  }

  // ── Light ThemeData ───────────────────────────────────────
  static ThemeData get light {
    final t = _lightTokens;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: t.bgCanvas,
      colorScheme: ColorScheme.light(
        primary: t.brandOrange,
        onPrimary: Colors.white,
        primaryContainer: t.brandOrange.withOpacity(0.12),
        onPrimaryContainer: t.brandOrangeDark,
        secondary: t.brandBlue,
        onSecondary: Colors.white,
        secondaryContainer: t.brandBlue.withOpacity(0.12),
        onSecondaryContainer: t.brandBlue,
        surface: t.bgSurface,
        onSurface: t.textPrimary,
        surfaceContainerHighest: t.bgElevated,
        onSurfaceVariant: t.textSecondary,
        outline: t.borderDefault,
        outlineVariant: t.divider,
        error: t.error,
        onError: Colors.white,
        errorContainer: t.error.withOpacity(0.12),
        onErrorContainer: t.error,
        inverseSurface: _Palette.darkSurface,
        onInverseSurface: _Palette.darkTextPrimary,
        scrim: Colors.black38,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.bgSurface,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: t.textPrimary,
        ),
        iconTheme: IconThemeData(color: t.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: t.navBar,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(t),
      outlinedButtonTheme: _outlinedButtonTheme(t),
      textButtonTheme: _textButtonTheme(t),
      inputDecorationTheme: _inputTheme(t),
      snackBarTheme: _snackBarTheme(t),
      cardTheme: _cardTheme(t),
      chipTheme: _chipTheme(t),
      bottomNavigationBarTheme: _bottomNavTheme(t),
      navigationBarTheme: _navigationBarTheme(t),
      dividerTheme: _dividerTheme(t),
      iconTheme: IconThemeData(color: t.textSecondary, size: 22),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.brandOrange),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.brandOrange
              : t.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.brandOrange.withOpacity(0.35)
              : t.bgElevated,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.brandOrange
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: t.borderDefault, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? t.brandOrange
              : t.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.bgSurface,
        modalBackgroundColor: t.bgSurface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: t.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          color: t.textSecondary,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.bgSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          color: t.textPrimary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: t.brandOrange,
        unselectedLabelColor: t.textSecondary,
        indicatorColor: t.brandOrange,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      extensions: [t, _lightTypography],
    );
  }
}

// ────────────────────────────────────────────────────────────
// 9. BuildContext EXTENSIONS  (ergonomic access)
// ────────────────────────────────────────────────────────────
extension AppThemeContext on BuildContext {
  /// Access color tokens: `context.tokens.brandOrange`
  RedditTokens get tokens => AppTheme.tokensOf(this);

  /// Access typography tokens: `context.rTypo.postTitle`
  RedditTypography get rTypo => AppTheme.typographyOf(this);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
