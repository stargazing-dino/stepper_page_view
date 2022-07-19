import 'package:collection/collection.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stepper_page_view/src/models/page_step.dart';
import 'package:stepper_page_view/src/utils/list_utils.dart';

typedef StepperFooterBuilder = Widget Function(
  BuildContext context,
  int currentPage,
  List<PageStep> pageSteps,
  VoidCallback? next,
  VoidCallback? previous,
);

typedef StepperPageIndicatorBuilder = Widget Function(
  BuildContext context,
  int currentPage,
  List<PageStep> pageSteps,
  ValueSetter<int>? animateToPage,
  ValueListenable<double> pageProgress,
);

typedef StepperPageItemBuilder = Widget Function(
  BuildContext context,
  int currentPage,
  List<PageStep> pageSteps,
);

class StepperPageView extends StatefulWidget {
  const StepperPageView({
    super.key,
    required this.pageSteps,
    this.pageController,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.onPageChanged,
    this.currentPage = 0,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.easeInOut,
    this.footerBuilder = defaultFooterBuilder,
    this.pageIndicatorBuilder = defaultPageIndicatorBuilder,
    this.itemBuilder = defaultItemBuilder,
    this.padding = const EdgeInsets.only(top: 16.0),
    this.contentPadding = const EdgeInsets.all(0),
  });

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [pageSteps] must not change.
  final List<PageStep> pageSteps;

  final int currentPage;

  final PageController? pageController;

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the page view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the page view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// If an explicit [ScrollBehavior] is provided to [scrollBehavior], the
  /// [ScrollPhysics] provided by that behavior will take precedence after
  /// [physics].
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Called whenever the page in the center of the viewport changes.
  final ValueChanged<int>? onPageChanged;

  final Duration pageTransitionDuration;

  final Curve pageTransitionCurve;

  final StepperFooterBuilder footerBuilder;

  final StepperPageIndicatorBuilder pageIndicatorBuilder;

  final StepperPageItemBuilder itemBuilder;

  final EdgeInsets padding;

  final EdgeInsets contentPadding;

  static Widget defaultFooterBuilder(
    BuildContext context,
    int currentPage,
    List<PageStep> pageSteps,
    VoidCallback? next,
    VoidCallback? previous,
  ) {
    return const SizedBox();
  }

  static Widget defaultPageIndicatorBuilder(
    BuildContext context,
    int currentPage,
    List<PageStep> pageSteps,
    ValueSetter<int>? animateToPage,
    ValueListenable<double> pageProgress,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(32.0),
        color: theme.colorScheme.primary.withAlpha(0x44),
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ValueListenableBuilder<double>(
            valueListenable: pageProgress,
            builder: (context, progress, _) {
              // progress goes up to pageSteps.length

              return Row(
                mainAxisSize: MainAxisSize.max,
                children: pageSteps.mapIndexed<Widget>(
                  (index, step) {
                    final maybeIcon = step.icon;

                    Widget iconChild;

                    if (maybeIcon == null) {
                      iconChild = Text('$index');
                    } else {
                      iconChild = maybeIcon;
                    }

                    final isPrevious = index < currentPage;
                    final isNext = index > currentPage;
                    final Color backgroundColor;
                    final Color iconColor;
                    final double elevation;

                    if (isPrevious) {
                      backgroundColor = theme.colorScheme.primary;
                      iconColor = theme.colorScheme.onPrimary;
                      elevation = 0.0;
                    } else if (isNext) {
                      backgroundColor = theme.colorScheme.surface;
                      iconColor = theme.colorScheme.onSurface.withAlpha(140);
                      elevation = 0.0;
                    } else /* current */ {
                      backgroundColor = theme.colorScheme.surface;
                      iconColor = theme.colorScheme.onSurface;
                      elevation = 12.0;
                    }

                    return Material(
                      shape: const CircleBorder(),
                      elevation: elevation,
                      color: backgroundColor,
                      child: IconButton(
                        padding: const EdgeInsets.all(4.0),
                        constraints: const BoxConstraints(),
                        color: iconColor,
                        onPressed: () => animateToPage?.call(index),
                        icon: iconChild,
                      ),
                    );
                  },
                ).intersperseIndexed(
                  (int index) {
                    final elementIndex = (index ~/ 2);
                    final currentProgress = progress - elementIndex;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: <Color>[
                                theme.colorScheme.primary,
                                theme.brightness == Brightness.dark
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.surface,
                              ],
                              stops: <double>[currentProgress, currentProgress],
                            ).createShader(bounds);
                          },
                          child: const DottedLine(
                            dashRadius: 6.0,
                            dashGapLength: 6.0,
                            dashColor: Colors.white,
                            lineThickness: 4.0,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget defaultItemBuilder(
    BuildContext context,
    int index,
    List<PageStep> pageSteps,
  ) {
    final pageStep = pageSteps[index];

    return pageStep.content;
  }

  @override
  State<StepperPageView> createState() => _StepperPageViewState();
}

class _StepperPageViewState extends State<StepperPageView> {
  late int currentPage;
  late PageController pageController;
  final pageProgress = ValueNotifier<double>(0.0);

  @override
  void initState() {
    currentPage = widget.currentPage;
    setupPageController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StepperPageView oldWidget) {
    if (widget.currentPage != currentPage) {
      updateCurrentPage();
      cleanupPageController();
      setupPageController();
    }

    if (widget.pageController != pageController) {
      cleanupPageController();
      setupPageController();
    }

    super.didUpdateWidget(oldWidget);
  }

  void updateCurrentPage() {
    currentPage = widget.currentPage;
    pageController.jumpToPage(currentPage);
  }

  void setupPageController() {
    pageController =
        widget.pageController ?? PageController(initialPage: currentPage);

    pageController.addListener(pageListener);
  }

  void cleanupPageController() {
    pageController.removeListener(pageListener);
    pageController.dispose();
  }

  void pageListener() {
    final maybePage = pageController.page;

    if (maybePage != null) {
      pageProgress.value = maybePage;
    }
  }

  @override
  void dispose() {
    cleanupPageController();
    super.dispose();
  }

  void next() {
    pageController.nextPage(
      duration: widget.pageTransitionDuration,
      curve: widget.pageTransitionCurve,
    );
  }

  void previous() {
    pageController.previousPage(
      duration: widget.pageTransitionDuration,
      curve: widget.pageTransitionCurve,
    );
  }

  void animateToPage(int index) {
    pageController.animateToPage(
      index,
      duration: widget.pageTransitionDuration,
      curve: widget.pageTransitionCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Scaffold(
        bottomNavigationBar: widget.footerBuilder(
          context,
          currentPage,
          widget.pageSteps,
          currentPage == widget.pageSteps.length - 1 ? null : next,
          currentPage == 0 ? null : previous,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            widget.pageIndicatorBuilder(
              context,
              currentPage,
              widget.pageSteps,
              animateToPage,
              pageProgress,
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: widget.pageSteps.length,
                onPageChanged: widget.onPageChanged ??
                    (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                reverse: widget.reverse,
                scrollDirection: widget.scrollDirection,
                physics: widget.physics,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: widget.contentPadding,
                    child: widget.itemBuilder(
                      context,
                      index,
                      widget.pageSteps,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
