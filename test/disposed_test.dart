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
  _DisposableObjectContainer(this.streamContainer);

  final _DisposableWrapperWithDisposableStream streamContainer;

  void addMessage(String message) {
    streamContainer.addMessage(message);
  }

  @override
  late final List<Disposable> disposables = [ streamContainer, ];
}


void main() {
  group('Test disposable streams', () {
    _DisposableWrapperWithDisposableStream? streamContainer =
      _DisposableWrapperWithDisposableStream();
    _DisposableObjectContainer? container =
      _DisposableObjectContainer(streamContainer);

    final _streamContainer = WeakReference(streamContainer);
    final _container = WeakReference(container);

    final elapsed = Stopwatch()..start();

    test('Test that objects are disposed.', () async {
      expect(
        container!.streamContainer.stream,
        emitsInOrder([
          '1',
          '2',
          // emitsDone,
          // cannot test for emits done, because
          // matcher creates strong reference
        ]),
      );
      

      // Do some work.
      container!.addMessage('1');
      container!.addMessage('2');

      // Make object unaccessible.
      streamContainer = null;
      container = null;

      // Wait for GC.
      while(_streamContainer.target != null || _container.target != null) {
        if (elapsed.elapsed > const Duration(seconds: 5))
          fail('Timeout');

        await Future<void>.delayed(const Duration(milliseconds: 1));
        // Feed memory to force GC.
        // ignore: unused_local_variable
        final bigChunkOfData = '0' * 1024 * 1024 * 5; // about 5mb of data.
      }

      expect(_streamContainer.target, isNull);
      expect(_container.target, isNull);
    });
  });
}
