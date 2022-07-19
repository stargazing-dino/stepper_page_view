import 'package:flutter/material.dart';

@immutable
class PageControlsDetails extends ControlsDetails {
  const PageControlsDetails({
    required super.currentStep,
    required super.stepIndex,
    super.onStepCancel,
    super.onStepContinue,
    this.onStepSelect,
  });

  final Function(int index)? onStepSelect;
}
