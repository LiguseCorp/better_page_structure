import 'dart:io';
import 'dart:ui';

// import 'package:doing/widget/better_localization.dart';
// import 'package:better_useful_extensions/better_useful_extensions.dart';
import 'package:better_page_structure/better_theme.dart';
import 'package:better_useful_extensions/better_useful_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:get/get.dart'; // Removed get import
import 'package:keframe/keframe.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

typedef ScrollPositionCallback = void Function(double position, double maxScrollExtent);
typedef FrameMarginCallback = void Function(double top, double bottom);

class PageStructure extends StatefulWidget {
  final dynamic title;
  final List<Widget> actions;
  final List<Widget> leftActions;
  final Widget bottom;
  final double bottomHeight;
  final Widget body;
  final bool isExtended;
  final bool useSafeArea;
  final bool keyboardSafeArea;
  final bool useMarginTop;
  final BackButtonType backButtonType;
  final bool showActionBar;
  final EdgeInsets padding;
  final Color? color;
  final Color? backgroundColor;
  final bool showTopScrollDivider;
  final Widget? floatingActionButton;
  final ScrollController? bodyScrollController;
  final ScrollPositionCallback? onScrollChange;
  final FrameMarginCallback? onFrameMarginChange;
  final VoidCallback? onBackButtonPressed;
  final bool isPage;

  const PageStructure({
    super.key,
    this.title = "",
    this.actions = const [],
    this.leftActions = const [],
    this.bottom = const SizedBox(),
    this.bottomHeight = 0,
    required this.body,
    required this.isExtended,
    this.useSafeArea = true,
    this.keyboardSafeArea = true,
    this.useMarginTop = true,
    this.backButtonType = BackButtonType.none,
    this.showActionBar = true,
    this.padding = const EdgeInsets.only(top: 60, left: 24, right: 24),
    this.bodyScrollController,
    this.backgroundColor,
    this.showTopScrollDivider = true,
    this.floatingActionButton,
    this.onScrollChange,
    this.onFrameMarginChange,
    this.onBackButtonPressed,
    this.color,
    this.isPage = false,
  });

  @override
  State<PageStructure> createState() => _PageStructureState();
}

class _PageStructureState extends State<PageStructure> {
  late final ScrollController _scrollController;

  // final _isScrollToTop = true.obs; // Removed get observable
  // final _isScrollToBottom = true.obs; // Removed get observable
  final ValueNotifier<bool> _isScrollToTop = ValueNotifier<bool>(true); // Replaced with ValueNotifier
  final ValueNotifier<bool> _isScrollToBottom = ValueNotifier<bool>(true); // Replaced with ValueNotifier

  @override
  void initState() {
    super.initState();
    _initializeScrollController();
    _setupScrollListeners();
  }

  void _initializeScrollController() {
    _scrollController = widget.bodyScrollController ?? ScrollController();
  }

  void _setupScrollListeners() {
    _scrollController.addListener(() {
      final position = _scrollController.position;
      // _isScrollToTop.value = position.pixels < 8; // Removed get observable
      // _isScrollToBottom.value = position.pixels > position.maxScrollExtent - 8; // Removed get observable
      _isScrollToTop.value = position.pixels < 8; // Updated ValueNotifier
      _isScrollToBottom.value = position.pixels > position.maxScrollExtent - 8; // Updated ValueNotifier
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isPage && Platform.isWindows ? _buildWindowsNavigationView() : _buildMainContent();
  }

  Widget _buildWindowsNavigationView() {
    return fluent.NavigationView(
      appBar: _buildWindowsAppBar(),
      content: _buildMainContent(),
    );
  }

  fluent.NavigationAppBar _buildWindowsAppBar() {
    final theme = Theme.of(context);
    return fluent.NavigationAppBar(
      backgroundColor: _getWindowsAppBarColor(theme),
      height: 40,
      automaticallyImplyLeading: false,
      title: const DragToMoveArea(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Material(
            type: MaterialType.transparency,
            child: Text("Doing"),
          ),
        ),
      ),
      actions: _buildWindowsAppBarActions(theme),
    );
  }

  Color? _getWindowsAppBarColor(ThemeData theme) {
    return theme.brightness == Brightness.light ? const Color(0xFFF0F0F0) : const Color(0xFF1E1E1E);
    // return Global.isWindowsWithoutMica ? (theme.brightness == Brightness.light ? const Color(0xFFF0F0F0) : const Color(0xFF1E1E1E)) : Colors.transparent;
  }

  Widget _buildWindowsAppBarActions(ThemeData theme) {
    return SizedBox(
      width: 138,
      height: 40,
      child: WindowCaption(
        brightness: fluent.FluentTheme.of(context).brightness,
        backgroundColor: _getWindowsAppBarColor(theme),
      ),
    );
  }

  Widget _buildMainContent() {
    return PopScope(
      onPopInvoked: _handlePopInvoked,
      canPop: widget.onBackButtonPressed == null,
      child: Material(
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
        child: AnnotatedRegion(
          value: _systemUiOverlayStyle(),
          child: Stack(
            children: [
              _buildBodyContent(),
              if (widget.showActionBar) _buildAppBar(),
              if (widget.bottomHeight != 0) _buildBottomBar(),
              if (widget.floatingActionButton != null) _buildFloatingActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  SystemUiOverlayStyle _systemUiOverlayStyle() {
    final brightness = Theme.of(context).brightness;
    return SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).colorScheme.surface,
      systemNavigationBarIconBrightness: brightness.reversed,
      statusBarIconBrightness: brightness.reversed,
      statusBarBrightness: brightness,
      statusBarColor: Colors.transparent,
    );
  }

  void _handlePopInvoked(bool didPop) {
    if (!didPop) {
      if (widget.onBackButtonPressed == null) {
        Navigator.pop(context);
      } else {
        widget.onBackButtonPressed?.call();
      }
    }
  }

  Widget _buildBodyContent() {
    return FrameSeparateWidget(
      child: widget.isExtended ? _buildExtendedBody() : _buildScrollableBody(),
    );
  }

  Widget _buildExtendedBody() {
    return widget.body.marginOnly(
      left: widget.padding.left,
      right: widget.padding.right,
    );
  }

  Widget _buildScrollableBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: widget.body.marginOnly(
        top: _calculateBodyTopMargin(),
        bottom: widget.bottomHeight,
        left: widget.padding.left,
        right: widget.padding.right,
      ),
    );
  }

  double _calculateBodyTopMargin() {
    return (widget.showActionBar ? 48 : 0) + (widget.useMarginTop ? 8 : 0) + (widget.useSafeArea ? BetterTheme.of(context).getFrameMargin().top : 0);
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: _handleDragStart,
        child: Stack(
          children: [
            _buildAppBarBackground(),
            _buildTitleRow(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildAppBarDivider(),
            )
          ],
        ),
      ),
    );
  }

  void _handleDragStart(DragStartDetails details) {
    if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
      windowManager.startDragging();
    }
  }

  Widget _buildAppBarBackground() {
    return Positioned.fill(
      child: ClipRect(
        // child: Obx(() => BackdropFilter( // Removed get Obx
        child: ValueListenableBuilder<bool>(
          // Replaced with ValueListenableBuilder
          valueListenable: _isScrollToTop,
          builder: (context, isScrollToTopValue, child) => BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isScrollToTopValue ? 0 : 10, // Updated to use isScrollToTopValue
              sigmaY: isScrollToTopValue ? 0 : 10, // Updated to use isScrollToTopValue
            ),
            child: _AnimatedAppBarBackground(
              isTop: isScrollToTopValue, // Updated to use isScrollToTopValue
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                _buildTitlePlaceholder(),
                _buildCenteredTitle(),
                _buildActionButtons(),
                _buildBackButton(),
              ],
            ).marginOnly(
              left: _backButtonLeftMargin,
              right: 24,
            ),
          ),
        ],
      ),
    ).marginOnly(top: _safeAreaTopMargin + (widget.useMarginTop ? 8 : 0), bottom: 8);
  }

  double get _backButtonLeftMargin => widget.backButtonType == BackButtonType.back ? 16 : 24;

  double get _safeAreaTopMargin => widget.useSafeArea ? BetterTheme.of(context).getFrameMargin().top : 0;

  Widget _buildTitlePlaceholder() {
    return Opacity(
      opacity: 0,
      child: Row(
        children: [_buildTitleWidget()],
      ),
    );
  }

  Widget _buildCenteredTitle() {
    return Positioned(
      left: _titleHorizontalMargin,
      right: _titleHorizontalMargin,
      child: Center(child: _buildTitleWidget()),
    );
  }

  double get _titleHorizontalMargin => widget.backButtonType != BackButtonType.none ? 72 : 0;

  Widget _buildTitleWidget() {
    if (widget.title is String) {
      return Text(
        widget.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return widget.title is Widget ? widget.title : const SizedBox();
  }

  Widget _buildActionButtons() {
    return Positioned(
      right: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.actions,
      ),
    );
  }

  Widget _buildBackButton() {
    if (widget.backButtonType == BackButtonType.none) return const SizedBox();

    return Positioned(
      left: 0,
      child: _BackButton(
        type: widget.backButtonType,
        color: widget.color,
        onPressed: _handleBackPressed,
      ),
    );
  }

  void _handleBackPressed() {
    if (widget.onBackButtonPressed == null) {
      Navigator.pop(context);
    } else {
      widget.onBackButtonPressed?.call();
    }
  }

  Widget _buildAppBarDivider() {
    return Row(
      children: [
        Expanded(
          // child: Obx(() => AnimatedContainer( // Removed get Obx
          child: ValueListenableBuilder<bool>(
            // Replaced with ValueListenableBuilder
            valueListenable: _isScrollToTop,
            builder: (context, isScrollToTopValue, child) => AnimatedContainer(
              height: 1,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(_appBarDividerOpacity(isScrollToTopValue)), // Updated to use isScrollToTopValue
              duration: const Duration(milliseconds: 200), // Replaced milliseconds extension
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
      ],
    );
  }

  double _appBarDividerOpacity(bool isScrollToTopValue) => isScrollToTopValue // Updated to accept isScrollToTopValue
      ? 0
      : widget.showTopScrollDivider
          ? 0.05
          : 0;

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: widget.bottomHeight,
      child: Column(
        children: [
          _buildBottomDivider(),
          widget.bottom,
        ],
      ),
    );
  }

  Widget _buildBottomDivider() {
    return Row(
      children: [
        Expanded(
          // child: Obx(() => AnimatedContainer( // Removed get Obx
          child: ValueListenableBuilder<bool>(
            // Replaced with ValueListenableBuilder
            valueListenable: _isScrollToBottom,
            builder: (context, isScrollToBottomValue, child) => AnimatedContainer(
              height: 1,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(_bottomDividerOpacity(isScrollToBottomValue)), // Updated to use isScrollToBottomValue
              duration: const Duration(milliseconds: 200), // Replaced milliseconds extension
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
      ],
    );
  }

  double _bottomDividerOpacity(bool isScrollToBottomValue) => isScrollToBottomValue ? 0 : 0.05; // Updated to accept isScrollToBottomValue

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: widget.bottomHeight + 32,
      right: 32,
      child: widget.floatingActionButton!,
    );
  }
}

class _AnimatedAppBarBackground extends StatelessWidget {
  final bool isTop;

  const _AnimatedAppBarBackground({required this.isTop});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Replaced milliseconds extension
      curve: Curves.fastOutSlowIn,
      color: isTop ? Theme.of(context).cardColor.withOpacity(0.0) : Theme.of(context).cardColor.withOpacity(0.7),
    );
  }
}

class _BackButton extends StatelessWidget {
  final BackButtonType type;
  final Color? color;
  final VoidCallback onPressed;

  const _BackButton({
    required this.type,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = BetterTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (type == BackButtonType.back)
          Icon(
            CupertinoIcons.back,
            size: 24,
            color: color ?? theme.primaryColor,
          ).marginOnly(right: 2),
        Text(
          _buttonText,
          style: TextStyle(
            color: color ?? theme.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).interact(onTap: onPressed);
  }

  String get _buttonText {
    switch (type) {
      case BackButtonType.back:
        return "返回"; // Removed .i18n
      case BackButtonType.done:
        return "完成"; // Removed .i18n
      case BackButtonType.cancel:
        return "取消"; // Removed .i18n
      default:
        return "";
    }
  }
}

enum BackButtonType { none, back, cancel, done }

class BetterInit {
  static init() async {
    await windowManager.ensureInitialized();
  }
}
