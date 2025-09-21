import 'package:flutter/widgets.dart';
import 'package:flutter_islands/src/controllers/control.dart';
import 'package:flutter_islands/src/controllers/island_control.dart';
import 'package:flutter_islands/src/controllers/layout_control.dart';
import 'package:provider/provider.dart';

extension ContextExtension on BuildContext {
  /// Get the nearest layout controller of type [T].
  /// If you are not sure wether this type [T] exists at this point, make it nullable.
  T getLayoutControl<T extends LayoutControl?>() {
    return read<T>();
  }

  /// Get the nearest island controller of type [T].
  /// If you are not sure wether this type [T] exists at this point, make it nullable.
  T getIslandControl<T extends IslandControl?>() {
    return read<T>();
  }

  void propegateToLayout<T extends LayoutControl>({required Control control}) {
    final layoutControl = getLayoutControl<T>();

    layoutControl.registerControl(control);
  }
}
