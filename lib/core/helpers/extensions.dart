import 'package:flutter/widgets.dart';

/// Parses API-supplied hex color strings (e.g. a `CategoryResource.color`
/// like `#A78BFA`) into a [Color].
extension HexColor on String {
  /// Accepts `#RRGGBB` or `#AARRGGBB` (leading `#` optional). Falls back to
  /// [fallback] for anything else, so a malformed/missing color from the
  /// API never crashes the UI.
  Color toColor({Color fallback = const Color(0xFFA78BFA)}) {
    var hex = replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return fallback;
    final value = int.tryParse(hex, radix: 16);
    return value != null ? Color(value) : fallback;
  }
}

extension Navigation on BuildContext {
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(
      this,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
    required RoutePredicate predicate,
  }) {
    return Navigator.of(
      this,
    ).pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  void pop() => Navigator.of(this).pop();
}
