# flutter_islands

State management optimized for desktop applications, divide you application into islands, have finegrained control over these islands and fully isolate every imperative action that needs to be done from your widget. Heavily inspired by [stacked](https://stacked.filledstacks.com/).

## Features

 - Layout your applications using `LayoutWidget`
 - Have finegrained control over your applications state using `IslandWidget`s and `IslandControl`s
 - Create Services and make them available through dependency injection outside of the widget tree
 - Control imperative flutter elements (dialogs, navigation, toasts) as a service within the IslandControl, keep your widgets clean.
 - Toast notifications.
 - Easily create unit tests for each of your islands and layouts

## Getting started

Add `flutter_islands` to your project by running:

```flutter pub add flutter_islands```


If you are using vscode, add the [flutter_islands vscode snippets]()(do not exist yet as this is a concept readmes).

## Core Concepts

### Islands
An application is built with multiple islands, layed out in a specific way using layouts.
It might look something like this:

![Layout image](https://i.imgur.com/UWKUDaG.png)

These islands all have their own notifier that controls the state of the island, this notifier is called either `IslandControl` or `LayoutControl`.

Island and layout controls are available in any descendant of the island or layout that they control.
```dart
final control = context.getIslandControl<MyIslandControl>();
final control = context.getLayoutControl<MyLayoutControl>();
```

## Island widget and control
### Island widget
An island widget looks like this:

```dart
///Islands are a special type of widget.
///The mixin is here to implement some other builders the island has (which we will get into later)
class MyIsland extends IslandWidget with DefaultIslandBuilders{
    const MyIsland({super,key})


    @override
    ///This builder will be used when the notifier is not busy.
    Widget builder(BuildContext context, MyControl control){
        return Column(children: [
            Text(control.count.toString()),
            FilledButton(
                onPressed: control.increment, 
                child: Text('Increment')
            )
        ]);
    }

    @override
    void createControl(BuildContext context) => MyControl()
}
```

Any time the control calls for the ui to be rebuilt, the builder function will run.

### IslandControl
A simple control looks like this:
```dart
class MyControl extends IslandControl{
    int count = 0;

    void increment(){
        count++;
        //this will rebuild the island
        rebuildUi()
    }
}
```

For simple widgets like these, a simple stateful component will suffice. 
Most of the time islands will be used to do async operations, that is why the IslandControl comes with some built in functionalities:
 - Async state: a control is either busy or not busy, here busy means that it is currently running/waiting on some async process.
 - Error state: the controls async helping methods automatically
 - Context Run: isolate pieces of functionality that depend on context, like dialogs or snackbars, and make them run from your notifier

```dart
class MyControl extends IslandControl{
    MyControl() : _service = getService(), _flutterService = getService();

    final DataService _service;
    final FlutterService _flutterService;

    Data? data;

    //use run to quickly run a future and automatically set busy flags
    void operation() async{
        data = await runAsync(
            _service.getData()
            onSucces: _flutterService.showToast(
                ToastType.succes,
                'Got data'
            )
        )
    }

    //use try if you do not want to set any flags
    void otherOperation() async{
        setBusy();
        data = await tryAsync(
            _service.getData()
            onSucces: _flutterService.showToast(
                ToastType.succes,
                'Got data'
            )
        )
        setNotBusy();
    }
}
```

The busy and error states can be reflected in the ui by supplying additional builders to the `IslandWidget`:
```dart
class MyIsland extends IslandWidget{
    const MyIsland({super,key})

    Widget busyBuilder(BuildContext context, MyControl control){
        //build loading indicators
    }

    Widget errorBuilder(BuildContext context, MyControl control){
        //build failure widget
    }

    @override
    Widget builder(BuildContext context, MyControl control){
        //build regular ui
    }

    @override
    void createControl(BuildContext context) => MyControl()
}
```
It is also possible to implement some generic version of these builders using a `mixin` like in [the previous Island example](#island-widget).
You can make your own mixin but there are also a few mixins included in this package:
 - `ToLayoutMixin<Layout>`: a mixin that redirects busyBuilder and errorBuilder to the specified layout.
   If multiple islands propegate to the layout, the layout will stay in busy state until all of them are done. 
 - `DefaultBuildersMixin`: a mixin with some default implementation for the builders.


### Layout widget and control
A layout widget is a special kind of island, it is used to orchestrate child islands. 

It serves two main purposes:
 1. Determine the way the islands are laid out in the ui.
 2. Provide shared state for islands beneath it in the widget tree.

In desktop applications, it is often the case that a specific layout also comes with some kind of shared object that multiple islands might need. For example: An article page might have a thumbnail island, a content island and a comments section island. All these islands need acces to the article information and are in the same layout. Hence it makes sence to combine these two things together.

An example layout widget might look like this

```dart
class MyLayout extends LayoutWidget{
    @override
    Widget builder(BuildContext context, BoxConstraints constraints, MyControl control){
        return Column(children: [
            Text(control.count.toString()),
            FilledButton(
                onPressed: control.increment, 
                child: Text('Increment')
            )
        ]);
    }

    @override
    void createControl(BuildContext context) => MyControl()
}
```

The layout control functions the same as the island control, the only difference is that you extend `LayoutControl` instead of `IslandControl`. This means that currently this distinction is only for readability purposes.

The recommended way to pass layouts to islands is the following:
```dart
class MyControl extends IslandControl{
    MyControl({required this.layoutControl});

    final LayoutControlA layoutControl;
}

class MyIsland extends IslandWidget with DefaultIslandBuilders{
    const MyIsland({super,key})


    @override
    ///This builder will be used when the notifier is not busy.
    Widget builder(BuildContext context, MyControl control){
        ///
    }

    @override
    void createControl(BuildContext context) => MyControl(layoutControl: context.getLayout())
}
```

This makes it very clear which island depends on its layout and which island does not.

## Context Functions
To run pieces of code that depend on context, like dialogs and snackbars, we can make use of context functions.
A context function is simply a function with the following format `Future<Type> doSomething(BuildContext context, ControlY control)`.
Lets illustrate the use of context functions with an example:
```dart
///shows a dialog that asks the user for confirmation, the dialog yields true, false or null.
Future<bool?> showConfirmDialog(BuildContext context, ConfirmIslandControl control){
    return showDialog(context: context, builder: (_) => ConfirmDialog());
}

///Now we can use this function in a control:
class ConfirmIslandControl extends IslandControl{
    bool confirmed = false;
    
    void confirm() async{
        //runContext runs the function with the islands context.
        confirmed = await runContext(showConfirmDialog) ?? false;
    }
}

```


## Testing
All controls are testable individually, to test context functions, a few test only methods are available on controls.
This is better illustrated with an example, lets test the functionality of our `ConfirmIslandControl` from [# Context Functions](#context-functions).
```dart
test('ConfirmIsland', (){
    final control = ConfirmIslandControl()
    control.confirm();

    expect(control.didRun(showConfirmDialog), true)
    control.returnFor(showConfirmDialog, true)
    //async gap...
    expect(control.confirmed, true)
})
```

The benefit of this bit of extra setup is that now dialog flows and other flutter elements can also be tested programatically in pure dart. Which is way faster than having to run flutter for the test, and also more consistent.