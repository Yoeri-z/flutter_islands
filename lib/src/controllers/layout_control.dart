import 'package:flutter/foundation.dart';
import 'package:flutter_islands/src/controllers/control.dart';

/// The Layout Controller, this contoller can be passed to a [LayoutWidget] to control the ui of that widget.
abstract class LayoutControl extends Control {
  LayoutControl({super.startsBusy});

  final Set<Control> _registeredControllers = {};

  List<Control> get _busyControllers => [
    for (final controller in _registeredControllers) controller,
  ];

  @override
  bool get isBusy => super.isBusy || _busyControllers.isNotEmpty;

  @internal
  bool get hasRegisteredControls => _registeredControllers.isNotEmpty;

  ///Register a which busy state should be propegated to this controller
  @internal
  void registerControl<T extends Control>(T controller) {
    _registeredControllers.add(controller);
  }
}
