import 'package:either_dart/either.dart';
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

typedef StepperFormPageIndicatorBuilder = Widget Function(
  BuildContext context,
  List<FormPageStep> pageSteps,
  PageControlsDetails pageControlsDetails,
  ValueListenable<double> pageProgress,
);

typedef StepperPageItemBuilder = Widget Function(
  BuildContext context,
  int currentPage,
  List<PageStep> pageSteps,
);

typedef StepperFormPageItemBuilder = Widget Function(
  BuildContext context,
  int currentPage,
  List<FormPageStep> pageSteps,
  GlobalKey<FormState> formKey,
);

typedef FormRequestNextPage = bool Function(
  int currentPage,
  List<FormPageStep> pageSteps,
  List<GlobalKey<FormState>> formKeys,
);

// TODO: Let's redo this one more time where instead we can have the PageStep
// be an either type of PageStep or FormPageStep... Perchance. (why are we
// saying this???)

// TODO:

class StepperPageView extends StatefulWidget {
  StepperPageView({
    super.key,
    required List<PageStep> pageSteps,
    this.pageController,
    this.initialPage,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.onPageChanged,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.easeInOut,
    StepperPageIndicatorBuilder? headerIndicatorBuilder,
    StepperPageItemBuilder? pageBuilder,
    this.pagePadding = const EdgeInsets.all(0),
  })  : headerIndicatorBuilder = const Left(defaultPageIndicatorBuilder),
        pageSteps = Left(pageSteps),
        pageBuilder = const Left(defaultPageBuilder),
        onRequestNextPage = const Left(null);

  StepperPageView.form({
    super.key,
    required List<FormPageStep> pageSteps,
    this.pageController,
    this.initialPage,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.onPageChanged,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.easeInOut,
    StepperFormPageIndicatorBuilder? headerIndicatorBuilder,
    this.pagePadding = const EdgeInsets.all(0),
    required FormRequestNextPage onRequestNextPage,
  })  : headerIndicatorBuilder = const Right(defaultPageIndicatorBuilder),
        pageSteps = Right(pageSteps),
        pageBuilder = const Right(defaultFormPageBuilder),
        onRequestNextPage = Right(onRequestNextPage);

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [pageSteps] must not change.
  final Either<List<PageStep>, List<FormPageStep>> pageSteps;

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

  final Either<void, FormRequestNextPage> onRequestNextPage;

  /// The duration spent transitioning from page to page.
  final Duration pageTransitionDuration;

  /// The curve to use when animating from page to page.
  final Curve pageTransitionCurve;

  /// A builder for the page indicator of the stepper.
  final Either<StepperPageIndicatorBuilder, StepperFormPageIndicatorBuilder>
      headerIndicatorBuilder;

  /// A builder for the content of the page.
  ///
  /// Override this if you need more customization than the default content
  /// field on a step can provider or if you need all pages to share some sort
  /// of common widget.
  final Either<StepperPageItemBuilder, StepperFormPageItemBuilder> pageBuilder;

  final EdgeInsets pagePadding;

  static Widget defaultPageIndicatorBuilder(
    BuildContext context,
    List<PageStep> pageSteps,
    PageControlsDetails pageControlsDetails,
    ValueListenable<double> pageProgress,
  ) {
    return SliverToBoxAdapter(
      child: DefaultPageIndicator(
        pageSteps: pageSteps,
        pageControlsDetails: pageControlsDetails,
        pageProgress: pageProgress,
      ),
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

  static Widget defaultFormPageBuilder(
    BuildContext context,
    int index,
    List<FormPageStep> pageSteps,
    GlobalKey<FormState> formKey,
  ) {
    final formPageStep = pageSteps[index];

    return Form(
      key: formKey,
      autovalidateMode: formPageStep.autovalidateMode,
      onChanged: formPageStep.onChanged,
      onWillPop: formPageStep.onWillPop,

      /// This form allows the content to call Form.of(context) to do validation
      /// and stuff.
      child: Builder(
        builder: (context) {
          return formPageStep.content;
        },
      ),
    );
  }

  @override
  State<StepperPageView> createState() => _StepperPageViewState();
}

class _StepperPageViewState extends State<StepperPageView> {
  late int currentStep;
  late PageController pageController;
  late final pageProgress = ValueNotifier<double>(0.0);
  late final Either<void, List<GlobalKey<FormState>>> formKeys;

  /// We use this to know the direction a user is going.
  late ScrollDirection scrollDirection = ScrollDirection.forward;

  @override
  void initState() {
    pageController = widget.pageController ??
        PageController(initialPage: widget.initialPage ?? 0);
    attachPageController(pageController);
    currentStep = widget.initialPage ?? 0;
    pageProgress.value = currentStep.toDouble();

    formKeys = widget.pageSteps.fold(
      (_) => const Left(null),
      (formPageSteps) {
        final formKeysToReturn = formPageSteps.map((formPageStep) {
          return formPageStep.key ??
              GlobalKey<FormState>(debugLabel: 'Title: ${formPageStep.title}');
        }).toList();

        return Right(formKeysToReturn);
      },
    );

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

    final oldPageSteps = widget.pageSteps;
    final newPageSteps = widget.pageSteps;

    // Instead of erroring we can do some other logic where we just reset the
    // form keys to the new length.
    if (oldPageSteps.isLeft && newPageSteps.isRight) {
      final newFormKeys = newPageSteps.right;
      final oldFormKeys = oldPageSteps.left;

      if (oldFormKeys.length != newFormKeys.length) {
        throw Exception(
          'The number of form keys must not change. '
          'Old: ${oldFormKeys.length}, new: ${newFormKeys.length}',
        );
      }

      for (var i = 0; i < oldFormKeys.length; i++) {
        if (oldFormKeys[i] != newFormKeys[i]) {
          throw Exception(
            'The form keys must not change. '
            'Old: ${oldFormKeys[i]}, new: ${newFormKeys[i]}',
          );
        }
      }
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
    final int stepIndex;
    final pageStepsLength = widget.pageSteps.fold(
      (pageSteps) => pageSteps.length,
      (pageSteps) => pageSteps.length,
    );

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
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: widget.headerIndicatorBuilder.fold(
                    (pageBuilder) {
                      final pageSteps = widget.pageSteps.left;

                      return pageBuilder(
                        context,
                        pageSteps,
                        controlsDetails,
                        pageProgress,
                      );
                    },
                    (formPageBuilder) {
                      final formPageSteps = widget.pageSteps.right;

                      return formPageBuilder(
                        context,
                        formPageSteps,
                        controlsDetails,
                        pageProgress,
                      );
                    },
                  ),
                ),
              ];
            },
            // TODO: We need all the parameters of a PageView covered
            // or we need to allow the user to create the PageView...
            // One of the two
            body: PageView.builder(
              controller: pageController,
              itemCount: pageStepsLength,
              onPageChanged: (index) {
                setState(() => currentStep = index);

                widget.onPageChanged?.call(index);
              },
              reverse: widget.reverse,
              scrollDirection: widget.scrollDirection,
              physics: widget.physics,
              itemBuilder: (context, index) {
                return CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: widget.pageBuilder.fold(
                        (pageBuilder) {
                          final pageSteps = widget.pageSteps.left;

                          return pageBuilder(
                            context,
                            index,
                            pageSteps,
                          );
                        },
                        (formPageBuilder) {
                          final formPageSteps = widget.pageSteps.right;
                          final formKey = formKeys.right[index];

                          return formPageBuilder(
                            context,
                            index,
                            formPageSteps,
                            formKey,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ...widget.onRequestNextPage.fold(
            (_) => [],
            (onRequestNextPage) {
              return [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () {
                        final canContinue = onRequestNextPage(
                          currentStep,
                          widget.pageSteps.right,
                          formKeys.right,
                        );

                        if (canContinue) {
                          onNextPage();
                        }
                      },
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
