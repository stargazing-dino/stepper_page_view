import 'package:flutter/material.dart';

/// An extension of [Step] to allow for a custom icon to be used.
class PageStep extends Step {
  const PageStep({
    required Widget title,
    this.icon,
    required Widget content,

    // TODO: currently don't do anything with these values
    Widget? subtitle,
    StepState state = StepState.indexed,
    bool isActive = false,
  }) : super(
          title: title,
          subtitle: subtitle,
          content: content,
          state: state,
          isActive: isActive,
        );

  /// The icon to show in the stepper.
  final Icon? icon;
}
