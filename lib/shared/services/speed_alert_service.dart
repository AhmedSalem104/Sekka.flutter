import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';

class SpeedAlertService {
  SpeedAlertService._();
  static final instance = SpeedAlertService._();

  final _tts = FlutterTts();
  StreamSubscription<Position>? _positionSub;
  bool _isWarning = false;
  DateTime? _lastWarningTime;

  int _speedLimitKmh = 60;
  bool _enabled = false;

  double _currentSpeedKmh = 0;
  double get currentSpeedKmh => _currentSpeedKmh;

  final _speedController = StreamController<double>.broadcast();
  Stream<double> get speedStream => _speedController.stream;

  void updateSettings({required bool enabled, required int speedLimit}) {
    _enabled = enabled;
    _speedLimitKmh = speedLimit;
    if (_enabled && _positionSub == null) {
      _startTracking();
    } else if (!_enabled) {
      _stopTracking();
    }
  }

  void _startTracking() {
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_onPosition);
    dev.log('Speed tracking started', name: 'SpeedAlert');
  }

  void _stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    _currentSpeedKmh = 0;
    _speedController.add(0);
    dev.log('Speed tracking stopped', name: 'SpeedAlert');
  }

  void _onPosition(Position position) {
    _currentSpeedKmh = position.speed * 3.6;
    if (_currentSpeedKmh < 0) _currentSpeedKmh = 0;
    _speedController.add(_currentSpeedKmh);

    if (_currentSpeedKmh > _speedLimitKmh) {
      _triggerWarning();
    } else {
      _isWarning = false;
    }
  }

  void _triggerWarning() {
    final now = DateTime.now();
    if (_isWarning &&
        _lastWarningTime != null &&
        now.difference(_lastWarningTime!).inSeconds < 15) {
      return;
    }

    _isWarning = true;
    _lastWarningTime = now;

    HapticFeedback.heavyImpact();
    _tts.speak('سرعتك عالية، هدّي شوية');

    dev.log(
      'SPEED WARNING: ${_currentSpeedKmh.toStringAsFixed(0)} km/h > $_speedLimitKmh km/h',
      name: 'SpeedAlert',
    );
  }

  void dispose() {
    _stopTracking();
    _speedController.close();
  }
}
