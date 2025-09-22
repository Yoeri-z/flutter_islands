import 'package:flutter/widgets.dart';
import 'package:flutter_islands/flutter_islands.dart';
import 'package:provider/provider.dart';

//I chose to implement this widget with element instead of just a stateless widget with a context.watch.
//This is so it is possible to remove the internal dependance on provider later on and also makes it possible to create better diagnostics.

///The base class of a widget that is controlled by a [Control]
abstract class ControlledWidget<T extends Control> extends Widget {
  ///The base class of a widget that is controlled by a [Control]
  const ControlledWidget({super.key});

  ///Create the control for this widget
  T createControl(BuildContext context);

  ///A builder that will be used when [control] is in busy state.
  Widget busyBuilder(BuildContext context, T control);

  ///A builder that will be used when [control] has an error.
  Widget errorBuilder(BuildContext context, T control);

  ///The root builder is used to call the actual builder with potentially more parameters
  Widget rootBuilder(BuildContext context, T control);

  @override
  ControlElement createElement() => ControlElement(this);
}

///The element for a [ControlledWidget]. Stores the [ControlledWidget]'s [Control] and propegates to the correct builders.
class ControlElement<T extends IslandControl> extends ComponentElement {
  ControlElement(super.widget) {
    control = typedWidget.createControl(this);
    control.element = this;
  }

  /// The control stored in this element.
  late final T control;

  /// [widget] parsed to the correct type.
  ControlledWidget<T> get typedWidget => widget as ControlledWidget<T>;

  @override
  Widget build() {
    //TODO: Remove dependance on provider
    return ChangeNotifierProvider.value(
      value: control,
      builder: (context, _) {
        if (control.hasError) return typedWidget.errorBuilder(this, control);
        if (control.isBusy) return typedWidget.busyBuilder(this, control);
        return typedWidget.rootBuilder(this, control);
      },
    );
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    control.addListener(markNeedsBuild);
  }

  @override
  void unmount() {
    control.dispose();
    super.unmount();
  }
}
