import 'package:flutter/widgets.dart';
import 'package:flutter_islands/src/controllers/control.dart';

/// Control for an island, this control can be passed to an [IslandWidget] to control the ui of that widget.
abstract class IslandControl extends Control {
  IslandControl({super.startsBusy});
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
