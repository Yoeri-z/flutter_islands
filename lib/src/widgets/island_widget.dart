import 'package:flutter/widgets.dart';
import 'package:flutter_islands/flutter_islands.dart';

///The base class for island widgets
abstract class IslandWidget<T extends IslandControl>
    extends ControlledWidget<T> {
  ///The base class for island widgets
  const IslandWidget({super.key});

  ///The builder for the island widget, used when the control is not busy and has no errors.
  Widget builder(BuildContext context, T control);

  @override
  Widget rootBuilder(BuildContext context, T control) =>
      builder(context, control);
}
