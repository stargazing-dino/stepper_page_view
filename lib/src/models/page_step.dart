import 'package:flutter/material.dart';

// TODO: If all we're doing is adding an nullable icon is that enough to
// warrant a super class.
/// An extension of [Step] to allow for a custom icon to be used.
class PageStep extends Step {
  const PageStep({
    this.icon,
    required super.title,
    required super.content,

    // TODO: currently don't do anything with these values
    super.subtitle,
    super.state = StepState.indexed,
    super.isActive = false,
  });

  /// The icon to show in the stepper.
  final Icon? icon;
}

class FormPageStep extends PageStep {
  const FormPageStep({
    super.icon,
    required super.title,

    // TODO: currently don't do anything with these values
    super.subtitle,
    super.state = StepState.indexed,
    super.isActive = false,
  }) : super(content: const SizedBox.shrink());
}
