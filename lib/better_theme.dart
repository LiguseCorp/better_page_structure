import 'package:flutter/material.dart';

@immutable
class BetterThemeData {
  final Color primaryColor;
  final EdgeInsets Function() getFrameMargin;

  const BetterThemeData({
    this.primaryColor = Colors.blue,
    this.getFrameMargin = _defaultGetFrameMargin,
  });

  static EdgeInsets _defaultGetFrameMargin() => EdgeInsets.zero;

  BetterThemeData copyWith({Color? primaryColor, EdgeInsets Function()? getFrameMargin}) {
    return BetterThemeData(primaryColor: primaryColor ?? this.primaryColor, getFrameMargin: getFrameMargin ?? this.getFrameMargin);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is BetterThemeData && runtimeType == other.runtimeType && primaryColor == other.primaryColor && getFrameMargin == other.getFrameMargin;

  @override
  int get hashCode => primaryColor.hashCode ^ getFrameMargin.hashCode;
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
