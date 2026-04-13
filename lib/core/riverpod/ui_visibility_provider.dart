import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track whether UI elements like app bars and bottom navigation bars
/// should be visible based on scroll direction.
final uiVisibilityProvider = StateProvider<bool>((ref) => true);
