import 'package:flutter/material.dart';

/// An extension of [Step] to allow for a custom icon to be used.
class PageStep extends Step {
  const PageStep({
    required super.title,
    this.icon,
    required super.content,

    // TODO: currently don't do anything with these values
    super.subtitle,
    super.state = StepState.indexed,
    super.isActive = false,
  });

  /// The icon to show in the stepper.
  final Icon? icon;
}
