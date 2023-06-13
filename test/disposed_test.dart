import 'dart:async';

import 'package:disposed/disposed.dart';
import 'package:test/test.dart';


class _DisposableWrapperWithDisposableStream extends DisposableContainer implements Disposable {
  final _disposableController = DisposableStreamController(
    StreamController<String>.broadcast(),
  );

  Stream<String> get stream => _disposableController.controller.stream;
 
  void addMessage(String message) {
    _disposableController.controller.add(message);
  }

  @override
  late final List<Disposable> disposables = [ _disposableController, ];

  @override
  void dispose() {

  }
}

class _DisposableObjectContainer extends DisposableContainer {
  _DisposableObjectContainer(this.innerStreamContainer);

  final _DisposableWrapperWithDisposableStream innerStreamContainer;

  void addMessage(String message) {
    innerStreamContainer.addMessage(message);
  }

  @override
  late final List<Disposable> disposables = [ innerStreamContainer, ];
}


void main() {
  group('Test disposable streams', () {
    _DisposableWrapperWithDisposableStream? innerStreamContainer =
      _DisposableWrapperWithDisposableStream();
    _DisposableObjectContainer? container =
      _DisposableObjectContainer(innerStreamContainer);

    final _innerStreamContainer = WeakReference(innerStreamContainer);
    final _container = WeakReference(container);

    test('Test that objects are disposed.', () async {
      final order = <String>[];

      var i = 0;
      final _streamEmit = expectAsync1<void, String>(
        count: 2,
        (message) {
          switch(i++) {
            case 0:
              expect(message, '1');
              order.add('message 1');
            case 1:
              expect(message, '2');
              order.add('message 1');
          }
        },
      );
      var streamDone = false;
      final _streamDone = expectAsync0<bool>(() {
        expect(streamDone, true);
        order.add('stream done');
        return false;
      });

      container!.innerStreamContainer.stream.listen(
        _streamEmit,
        onDone: () {
          streamDone = true;
        },
      );

      // Do some work.
      container!.addMessage('1');
      container!.addMessage('2');

      // Make object unaccessible.
      innerStreamContainer = null;
      container = null;

      final _innerStreamContainerDone = expectAsync0<bool>(() {
        order.add('inner stream container');
        return false;
      });
      final _containerDone = expectAsync0<bool>(() {
        order.add('container');
        return false;
      });

      await Future.wait([
        Future.doWhile(() async {
          await Future<void>.delayed(const Duration(milliseconds: 15));
          // ignore: unused_local_variable
          final bigChunkOfData = '0' * 1024 * 1024 * 50; // about 50mb of data.
          if (_innerStreamContainer.target != null)
            return true;
          else
            return _innerStreamContainerDone();
        }),
        Future.doWhile(() async {
          await Future<void>.delayed(const Duration(milliseconds: 15));
          // ignore: unused_local_variable
          final bigChunkOfData = '0' * 1024 * 1024 * 50; // about 50mb of data.
          if (_container.target != null)
            return true;
          else
            return _containerDone();
        }),
        Future.doWhile(() async {
          await Future<void>.delayed(const Duration(milliseconds: 15));
          // ignore: unused_local_variable
          final bigChunkOfData = '0' * 1024 * 1024 * 50; // about 50mb of data.
          if (!streamDone)
            return true;
          else
            return _streamDone();
        }),
      ]);

      expect(_innerStreamContainer.target, isNull);
      expect(_container.target, isNull);
      expect(
        order,
        orderedEquals([
          'message 1',
          'message 1',
          'container',
          'inner stream container',
          'stream done',
        ]),
      );
    });
  });
}
