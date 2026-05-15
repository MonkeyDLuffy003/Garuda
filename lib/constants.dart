import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// SERVER
// ─────────────────────────────────────────────
const String serverUrl = 'https://garuda-server-vhse.onrender.com';

// ─────────────────────────────────────────────
// COLORS — extracted from logo
// ─────────────────────────────────────────────
const Color bgColor        = Color(0xFFEFF6F4); // light mint background
const Color headerDark     = Color(0xFF0D5C6E); // deep teal header
const Color headerLight    = Color(0xFF1B8A7A); // teal gradient
const Color accentOrange   = Color(0xFFF57C3A); // orange accent from logo
const Color accentTeal     = Color(0xFF1B8A7A); // primary teal
const Color surfaceWhite   = Color(0xFFFFFFFF); // white surface
const Color userBubble     = Color(0xFFE8D5B0); // warm beige user bubble
const Color botBubble      = Color(0xFFFFFFFF); // white garuda bubble
const Color errorBubble    = Color(0xFFF4A0A0); // soft red error
const Color inputColor     = Color(0xFFE0EDE9); // mint input field
const Color textDark       = Color(0xFF1A2A2A); // dark text
const Color textGray       = Color(0xFF6B8A84); // gray text
const Color textWhite      = Color(0xFFFFFFFF);
const Color errorRed       = Color(0xFFE05555);
const Color successGreen   = Color(0xFF2ECC71);
const Color sessionsBg     = Color(0xFF1B8A7A);

// ─────────────────────────────────────────────
// GRADIENTS
// ─────────────────────────────────────────────
const LinearGradient headerGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0D5C6E), Color(0xFF1B8A7A)],
);

const LinearGradient splashGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF0D5C6E), Color(0xFF1B8A7A), Color(0xFFEFF6F4)],
  stops: [0.0, 0.5, 1.0],
);

// ─────────────────────────────────────────────
// TEXT STYLES
// ─────────────────────────────────────────────
const TextStyle appTitleStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w800,
  color: textWhite,
  letterSpacing: 2.0,
);

const TextStyle appSubtitleStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w400,
  color: Color(0xFFB8DDD8),
  letterSpacing: 1.5,
);
