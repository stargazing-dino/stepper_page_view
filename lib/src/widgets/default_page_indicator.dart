import 'package:collection/collection.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stepper_page_view/src/models/page_controls_details.dart';
import 'package:stepper_page_view/src/models/page_step.dart';
import 'package:stepper_page_view/src/utils/list_utils.dart';

/// A default page indicator with dots and circle pages
class DefaultPageIndicator extends StatelessWidget {
  const DefaultPageIndicator({
    super.key,
    required this.pageSteps,
    required this.pageControlsDetails,
    required this.pageProgress,
  });

  final List<PageStep> pageSteps;

  final PageControlsDetails pageControlsDetails;

  final ValueListenable<double> pageProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStep = pageControlsDetails.currentStep;
    final onStepSelect = pageControlsDetails.onStepSelect;

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

                    final isPrevious = index < currentStep;
                    final isNext = index > currentStep;
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
                        onPressed: onStepSelect == null
                            ? null
                            : () => onStepSelect(index),
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
}
