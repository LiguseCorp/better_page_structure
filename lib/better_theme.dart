import 'package:flutter/material.dart';

@immutable
class BetterThemeData {
  final Color primaryColor;
  final EdgeInsets frameMargin;

  const BetterThemeData({
    this.primaryColor = Colors.blue,
    this.frameMargin = const EdgeInsets.all(16),
  });

  BetterThemeData copyWith({Color? primaryColor, EdgeInsets? frameMargin}) {
    return BetterThemeData(primaryColor: primaryColor ?? this.primaryColor, frameMargin: frameMargin ?? this.frameMargin);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is BetterThemeData && runtimeType == other.runtimeType && primaryColor == other.primaryColor && frameMargin == other.frameMargin;

  @override
  int get hashCode => primaryColor.hashCode ^ frameMargin.hashCode;
}

class BetterTheme extends InheritedWidget {
  final BetterThemeData theme;

  const BetterTheme({
    super.key,
    required this.theme,
    required super.child,
  });

  static BetterThemeData of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<BetterTheme>();
    if (provider == null) {
      return const BetterThemeData();
    }
    return provider.theme;
  }

  @override
  bool updateShouldNotify(BetterTheme oldWidget) {
    return theme != oldWidget.theme;
  }
}
