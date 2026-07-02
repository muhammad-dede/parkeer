import 'dart:async';

import 'app_event.dart';

class AppEventBus {
  AppEventBus._();

  static final instance = AppEventBus._();

  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast();

  void fire(AppEvent event) {
    _controller.add(event);
  }

  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((e) => e is T).cast<T>();
  }
}
