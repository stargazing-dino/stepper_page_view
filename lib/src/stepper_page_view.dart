import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stepper_page_view/src/models/page_controls_details.dart';
import 'package:stepper_page_view/src/models/page_step.dart';
import 'package:stepper_page_view/src/widgets/default_page_indicator.dart';

typedef StepperPageIndicatorBuilder = Widget Function(
  BuildContext context,
  List<PageStep> pageSteps,
  PageControlsDetails pageControlsDetails,
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
    this.initialPage,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.onPageChanged,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.easeInOut,
    this.footerIndicatorBuilder,
    this.headerIndicatorBuilder = defaultPageIndicatorBuilder,
    this.pageBuilder = defaultPageBuilder,
    this.pagePadding = const EdgeInsets.all(0),
  });

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [pageSteps] must not change.
  final List<PageStep> pageSteps;

  final PageController? pageController;

  final int? initialPage;

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

  /// The duration spent transitioning from page to page.
  final Duration pageTransitionDuration;

  /// The curve to use when animating from page to page.
  final Curve pageTransitionCurve;

  /// A builder for the footer of the stepper.
  final StepperPageIndicatorBuilder? footerIndicatorBuilder;

  /// A builder for the page indicator of the stepper.
  final StepperPageIndicatorBuilder headerIndicatorBuilder;

  /// A builder for the content of the page.
  ///
  /// Override this if you need more customization than the default content
  /// field on a step can provider or if you need all pages to share some sort
  /// of common widget.
  final StepperPageItemBuilder pageBuilder;

  final EdgeInsets pagePadding;

  static Widget defaultPageIndicatorBuilder(
    BuildContext context,
    List<PageStep> pageSteps,
    PageControlsDetails pageControlsDetails,
    ValueListenable<double> pageProgress,
  ) {
    return DefaultPageIndicator(
      pageSteps: pageSteps,
      pageControlsDetails: pageControlsDetails,
      pageProgress: pageProgress,
    );
  }

  static Widget defaultPageBuilder(
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
  late int currentStep;
  late PageController pageController;
  late final pageProgress = ValueNotifier<double>(0.0);

  /// We use this to know the direction a user is going.
  late ScrollDirection scrollDirection = ScrollDirection.forward;

  @override
  void initState() {
    pageController = widget.pageController ??
        PageController(initialPage: widget.initialPage ?? 0);
    attachPageController(pageController);
    currentStep = widget.initialPage ?? 0;
    pageProgress.value = currentStep.toDouble();

    // The user provider a pageController and an initial page so should
    // set the page to their initial page. Argueably we shouldn't do anything.
    if (widget.pageController != null && widget.initialPage != null) {
      Future<void>.delayed(Duration.zero, () {
        if (mounted) {
          pageController.jumpToPage(currentStep);
        }
      });
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StepperPageView oldWidget) {
    final oldPageController = oldWidget.pageController;
    final newPageController = widget.pageController;

    if (oldPageController == null && newPageController != null) {
      cleanupPageController();
      pageController = newPageController;
      attachPageController(pageController);
    }

    if (widget.onPageChanged != oldWidget.onPageChanged) {
      pageController.removeListener(pageListener);
      pageController.addListener(pageListener);
    }

    super.didUpdateWidget(oldWidget);
  }

  void attachPageController(PageController pageController) {
    pageController.addListener(pageListener);
  }

  void pageListener() {
    final maybePage = pageController.page;

    if (maybePage != null) {
      pageProgress.value = maybePage;

      final ScrollDirection scrollDirectionToSet;

      if (maybePage > currentStep) {
        scrollDirectionToSet = ScrollDirection.forward;
      } else if (maybePage < currentStep) {
        scrollDirectionToSet = ScrollDirection.reverse;
      } else {
        scrollDirectionToSet = ScrollDirection.idle;
      }

      if (scrollDirectionToSet != scrollDirection && mounted) {
        setState(() {
          scrollDirection = scrollDirectionToSet;
        });
      }
    }
  }

  void cleanupPageController() {
    pageController.removeListener(pageListener);
    pageController.dispose();
  }

  @override
  void dispose() {
    // Do not clean up the users controller.
    if (widget.pageController == null) {
      cleanupPageController();
    }
    super.dispose();
  }

  void onNextPage() {
    pageController.nextPage(
      duration: widget.pageTransitionDuration,
      curve: widget.pageTransitionCurve,
    );
  }

  void onPreviousPage() {
    pageController.previousPage(
      duration: widget.pageTransitionDuration,
      curve: widget.pageTransitionCurve,
    );
  }

  void onAnimateToPage(int index) {
    pageController.animateToPage(
      index,
      duration: widget.pageTransitionDuration,
      curve: widget.pageTransitionCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final footerBuilder = widget.footerIndicatorBuilder;
    final int stepIndex;

    switch (scrollDirection) {
      case ScrollDirection.idle:
        stepIndex = currentStep;
        break;
      case ScrollDirection.forward:
        stepIndex = currentStep + 1;
        break;
      case ScrollDirection.reverse:
        stepIndex = currentStep - 1;
        break;
    }

    final controlsDetails = PageControlsDetails(
      currentStep: currentStep,
      stepIndex: stepIndex,
      onStepCancel: onPreviousPage,
      onStepContinue: onNextPage,
    );

    // TODO: If the user isn't going to pass a page indicator builder I
    // don't think I want the column.

    // TODO: What do you think of a CustomScrollView with a
    // PersistentHeader as the page indicator instead? Maybe we could have
    // both? I would require SliverFillRemaining or whatever its called
    // for the body.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        widget.headerIndicatorBuilder(
          context,
          widget.pageSteps,
          controlsDetails,
          pageProgress,
        ),
        Expanded(
          // TODO: We need all the parameters of a PageView covered
          // or we need to allow the user to create the PageView...
          // One of the two
          child: PageView.builder(
            controller: pageController,
            itemCount: widget.pageSteps.length,
            onPageChanged: (index) {
              setState(() => currentStep = index);

              widget.onPageChanged?.call(index);
            },
            reverse: widget.reverse,
            scrollDirection: widget.scrollDirection,
            physics: widget.physics,
            itemBuilder: (context, index) {
              return Padding(
                padding: widget.pagePadding,
                child: widget.pageBuilder(
                  context,
                  index,
                  widget.pageSteps,
                ),
              );
            },
          ),
        ),
        if (footerBuilder != null)
          footerBuilder(
            context,
            widget.pageSteps,
            controlsDetails,
            pageProgress,
          ),
      ],
    );
  }
}
