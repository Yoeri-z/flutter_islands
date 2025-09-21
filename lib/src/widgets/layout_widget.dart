import 'package:flutter/cupertino.dart';
import 'package:flutter_islands/src/controllers/layout_control.dart';
import 'package:flutter_islands/src/widgets/controlled_widget.dart';

///The base class for layout widgets.
abstract class LayoutWidget<T extends LayoutControl>
    extends ControlledWidget<T> {
  ///The base class for layout widgets.
  const LayoutWidget({super.key});

  ///The builder for the layout widget, used when the control is not busy and has no errors.
  Widget builder(BuildContext context, T control, BoxConstraints constraints);

  @override
  Widget rootBuilder(BuildContext context, T control) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(context, control, constraints),
    );
  }
}
