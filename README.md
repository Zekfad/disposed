# Disposed

Disposed library provides wrappers for automatic objects disposal
utilizing `Finalizer`.

## Notice

Inner `Disposable` objects of `DisposableContainer` **MUST** not have strong
references to parent container, failed to follow this rule will cause
_memory leak_ and object would not only be never disposed, but also
remain in memory as long as program is running.

## Features

* Using this package you can create object destructors.


## Usage

Example:

```dart
// Container with disposable, but also disposable itself.
class NotificationsProvider extends DisposableContainer implements Disposable {
  final _notificationsController = DisposableStreamController(
    StreamController<String>.broadcast(),
  );

  Stream<String> get notifications => _notificationsController.controller.stream;
 
  void notify(String message) {
    _notificationsController.controller.add(message);
  }

  @override
  late final List<Disposable> disposables = [ _notificationsController, ];

  @override
  void dispose() {
    // Pay attention that this will be called **BEFORE** [disposables] are
    // disposed.
    print('NotificationsProvider is disposed.');
  }
}

// Main container
class NotificationsCenter extends DisposableContainer {
  NotificationsCenter(this.provider);

  final NotificationsProvider provider;

  void notify(String message) {
    provider.notify(message);
  }

  @override
  late final List<Disposable> disposables = [ provider, ];
}
```

When instance of `NotificationsCenter` from example above
will become inaccessible internal `Finalizer` will dispose objects in following
order:

* `NotificationsProvider` - inner Disposable, also a Wrapper
* `DisposableStreamController` - inner Disposable

Notice that `NotificationsCenter` itself is only a wrapper (main one)
and it wont be disposed, only garbage collected by the language GC.

Such order is because parent object have references to children, therefore GC
destroys parent first, then children will lose references and will be destroyed.

See [example](example/disposed_example.dart) for more details.
