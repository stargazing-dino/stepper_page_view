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
    required super.content,
    this.key,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onChanged,
    this.onWillPop,
    super.icon,
    required super.title,

    // TODO: currently don't do anything with these values
    super.subtitle,
    super.state = StepState.indexed,
    super.isActive = false,
  });

  final GlobalKey<FormState>? key;

  /// Used to enable/disable form fields auto validation and update their error
  /// text.
  ///
  /// {@macro flutter.widgets.FormField.autovalidateMode}
  final AutovalidateMode autovalidateMode;

  /// Called when one of the form fields changes.
  ///
  /// In addition to this callback being invoked, all the form fields themselves
  /// will rebuild.
  final VoidCallback? onChanged;

  /// Enables the form to veto attempts by the user to dismiss the [ModalRoute]
  /// that contains the form.
  ///
  /// If the callback returns a Future that resolves to false, the form's route
  /// will not be popped.
  ///
  /// See also:
  ///
  ///  * [WillPopScope], another widget that provides a way to intercept the
  ///    back button.
  final WillPopCallback? onWillPop;
}
