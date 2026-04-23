import 'dart:developer' as dev;

import 'package:flutter/services.dart';

class FocusModeService {
  FocusModeService._();
  static final instance = FocusModeService._();

  static const _channel = MethodChannel('com.sekkaride.driver/dnd');

  bool _enabled = false;

  bool get isEnabled => _enabled;

  Future<bool> hasDndAccess() async {
    try {
      return await _channel.invokeMethod<bool>('hasAccess') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestDndAccess() async {
    try {
      await _channel.invokeMethod('requestAccess');
    } catch (e) {
      dev.log('Failed to request DND access: $e', name: 'FocusMode');
    }
  }

  Future<void> enable() async {
    _enabled = true;

    final hasAccess = await hasDndAccess();
    if (hasAccess) {
      await _channel.invokeMethod('enableDnd');
      dev.log('Focus mode ENABLED — DND ON', name: 'FocusMode');
    } else {
      await requestDndAccess();
      dev.log('Focus mode ENABLED — DND access needed', name: 'FocusMode');
    }
  }

  Future<void> disable() async {
    _enabled = false;

    try {
      await _channel.invokeMethod('disableDnd');
    } catch (_) {}
    dev.log('Focus mode DISABLED — DND OFF', name: 'FocusMode');
  }

  Future<void> toggle() async {
    if (_enabled) {
      await disable();
    } else {
      await enable();
    }
  }

  Future<void> pauseDnd() async {
    try {
      await _channel.invokeMethod('disableDnd');
      dev.log('DND paused (app in background)', name: 'FocusMode');
    } catch (_) {}
  }

  Future<void> resumeDnd() async {
    if (!_enabled) return;
    final hasAccess = await hasDndAccess();
    if (hasAccess) {
      await _channel.invokeMethod('enableDnd');
      dev.log('DND resumed (app in foreground)', name: 'FocusMode');
    }
  }

  bool shouldBlockNotification() => _enabled;
}
