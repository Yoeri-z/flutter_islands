import 'package:flutter/material.dart';
import 'package:flutter_islands/flutter_islands.dart';

Future<bool?> showConfirmationDialog(BuildContext context, Control _) async {
  return (await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Do you want to add 1 to the counter'),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ));
}

class CounterIslandControl extends IslandControl {
  int count = 0;

  void increment() async {
    final shouldAdd = await runContext(showConfirmationDialog);
    if (shouldAdd == null || !shouldAdd) return;

    count++;
    rebuildUi();
  }
}

class CounterIsland extends IslandWidget<CounterIslandControl>
    with DefaultBuildersMixin {
  const CounterIsland({super.key});

  @override
  CounterIslandControl createControl(BuildContext context) =>
      CounterIslandControl();

  @override
  Widget builder(BuildContext context, CounterIslandControl control) {
    return Scaffold(
      body: Center(child: Text(control.count.toString())),
      floatingActionButton: IconButton(
        onPressed: control.increment,
        icon: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: CounterIsland()));
}
