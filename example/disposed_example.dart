/// In this example we'll create notification center with notifications provider.
/// 
/// This will illustrate how we can create auto-closable [Stream]s.
library disposed_example;

import 'dart:async';

import 'package:disposed/disposed.dart';


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

class NotificationsCenter extends DisposableContainer {
  NotificationsCenter(this.provider);

  final NotificationsProvider provider;

  void notify(String message) {
    provider.notify(message);
  }

  @override
  late final List<Disposable> disposables = [ provider, ];
}


Future<void> main(List<String> args) async {
  // Create objects.
  NotificationsProvider? provider = NotificationsProvider();
  NotificationsCenter? center = NotificationsCenter(provider);

  // Track GC status via week references.
  final _provider = WeakReference(provider);
  final _center = WeakReference(center);

  // Listen for some notifications.
  center.provider.notifications.listen(
    (event) => print('New notification: $event'),
    onDone: () => print('Notifications done.'),
  );

  // Do some work.
  center.notify('Test!');
  await Future<void>.delayed(const Duration(milliseconds: 250));
  center.notify('Test 2!');

  // Make object unaccessible.
  provider = null;
  center = null;

  // Wait for GC.
  while(_provider.target != null || _center.target != null) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    // Feed memory to force GC.
    // ignore: unused_local_variable
    final bigChunkOfData = '0' * 1024 * 1024 * 5; // about 5mb of data.
  }

  print('Disposables are disposed, objects garbage collected, streams closed.');
}
