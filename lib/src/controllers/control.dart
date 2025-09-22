import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_islands/src/widgets/controlled_widget.dart';

typedef SuccesCallback<T> = void Function(T data);

typedef FailedCallback = void Function(Object error, StackTrace stackTrace);

typedef ContextAction<T, D extends Control> =
    Future<T?> Function(BuildContext context, D control);

///The base [Control] class
abstract class Control extends ChangeNotifier {
  @visibleForTesting
  static void setTesting() {
    _testing = true;
  }

  @visibleForTesting
  bool didRun<T, D extends Control>(ContextAction<T, D> action) {
    if (_testing) {}
    return _activeActions.containsKey(action);
  }

  @visibleForTesting
  void returnFor<T, D extends Control>(ContextAction<T, D> action, T value) {
    _activeActions[action]!.complete(value);
  }

  ///The element of the [ControlWidget] this [Control] is attached to.
  ///
  ///If element is null, this either means that runContext was called in the constructor or that we are unit testing the control.
  @internal
  ControlElement? element;

  static bool _testing = false;

  final _activeActions = <ContextAction, Completer>{};

  bool _isBusy;

  (Object, StackTrace)? _error;

  ///Constructs the controller
  ///
  ///setting [startsBusy] to false will make the controller start in a non busy state.
  Control({bool startsBusy = false}) : _isBusy = startsBusy;

  ///Wether or not this controller is currently busy.
  bool get isBusy => _isBusy;

  ///Wether or not this controller encountered an error
  bool get hasError => _error != null;

  ///Mark the controller as busy.
  ///
  ///This does not rebuild the ui.
  void setBusy() {
    _isBusy = true;
  }

  ///Mark the controller as not busy.
  ///
  ///This does not rebuild the ui
  void setNotBusy() {
    _isBusy = false;
  }

  /// run a function with acces to context, the control will make sure that the function is only run when the widget is active.
  ///
  /// When testing, use [didRun] and [returnFor].
  Future<T?> runContext<T, D extends Control>(
    ContextAction<T, D> action,
  ) async {
    if (element == null || !element!.mounted) {
      //register action to be completed programaticaly when testing
      if (_testing) {
        final completer = Completer<T>();
        _activeActions[action as ContextAction] = completer;
        return completer.future;
      }
      return null;
    }

    return await action(element as BuildContext, this as D);
  }

  ///Safely await a future, this method automatically calls [rebuildUi] to reflect the busy state.
  ///
  ///It does not [rebuildUi] after completion, you should do this yourself after everything in your controller is set.
  Future<T?> runAsync<T>(
    FutureOr<T> future, {
    SuccesCallback<T>? onSucces,
    FailedCallback? onFailed,
  }) async {
    setBusy();
    rebuildUi();
    final result = await tryAsync(
      future,
      onSucces: onSucces,
      onFailed: onFailed,
    );
    setNotBusy();
    return result;
  }

  ///Safely await a future.
  ///
  ///This method does not change the busy flag and also does not rebuild the ui
  Future<T?> tryAsync<T>(
    FutureOr<T> future, {
    bool shouldRethrow = false,
    SuccesCallback<T>? onSucces,
    FailedCallback? onFailed,
  }) async {
    late final T result;
    try {
      result = await future;
    } catch (e, st) {
      _error = (e, st);
      onFailed?.call(e, st);
      if (shouldRethrow) rethrow;
      return null;
    }
    onSucces?.call(result);
    return result;
  }

  ///Rebuild the ui attached to this controller.
  ///
  ///This method is just an alias for [notifyListeners].
  void rebuildUi() {
    notifyListeners();
  }
}
