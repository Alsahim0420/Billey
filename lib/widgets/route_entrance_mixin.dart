import 'package:flutter/material.dart';

/// Defers content animation until the enclosing route is actually visible.
/// Uses route status rather than a guessed delay or a muted ticker.
mixin RouteEntranceMixin<T extends StatefulWidget> on State<T> {
  Animation<double>? _entranceRoute;
  ModalRoute<dynamic>? _entranceModal;
  bool _entranceStarted = false;
  bool _entranceCheckScheduled = false;
  bool get entranceStarted => _entranceStarted;
  void startEntranceAnimation();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entranceStarted) return;
    _entranceModal = ModalRoute.of(context);
    final route = _entranceModal?.animation;
    if (route != _entranceRoute) {
      _entranceRoute?.removeStatusListener(_onEntranceStatus);
      _entranceRoute = route;
      route?.addStatusListener(_onEntranceStatus);
    }
    if (route == null || route.status == AnimationStatus.completed) {
      _startEntrance();
    }
  }

  void _onEntranceStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _startEntrance();
  }

  void _startEntrance() {
    // Flutter temporarily reports a completed animation while laying out an
    // offstage route for Hero measurement. It has not entered the screen yet.
    if (_entranceStarted || !mounted) return;
    if (_entranceModal?.offstage ?? false) {
      if (!_entranceCheckScheduled) {
        _entranceCheckScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _entranceCheckScheduled = false;
          if (mounted) _startEntrance();
        });
      }
      return;
    }
    if (_entranceRoute != null &&
        _entranceRoute!.status != AnimationStatus.completed) {
      return;
    }
    _entranceStarted = true;
    _entranceRoute?.removeStatusListener(_onEntranceStatus);
    startEntranceAnimation();
  }

  @override
  void dispose() {
    _entranceRoute?.removeStatusListener(_onEntranceStatus);
    super.dispose();
  }
}
