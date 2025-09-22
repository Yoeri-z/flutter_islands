import 'package:flutter/material.dart';
import 'package:flutter_islands/flutter_islands.dart';

mixin DefaultBuildersMixin<T extends Control> on ControlledWidget<T> {
  @override
  Widget errorBuilder(BuildContext context, Control control) {
    return Center(child: Text('A problem occured.'));
  }

  @override
  Widget busyBuilder(BuildContext context, Control control) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

///Make the layout busy if this island is busy, give the layout an error if this island has an error.
mixin ToLayoutMixin<T extends LayoutControl> on ControlledWidget {
  @override
  Widget errorBuilder(BuildContext context, Control control) {
    context.propegateToLayout<T>(control: control);
    return SizedBox.shrink();
  }

  @override
  Widget busyBuilder(BuildContext context, Control control) {
    context.propegateToLayout(control: control);
    return SizedBox.shrink();
  }
}
