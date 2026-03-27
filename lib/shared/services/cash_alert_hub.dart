import 'dart:convert';
import 'dart:developer' as dev;
import '../storage/token_storage.dart';
import 'signalr_service.dart';

/// Real-time cash alert hub.
///
/// Server→Client events:
/// - `CashThresholdExceeded` → driver exceeded cash limit
/// - `SettlementReminder` → reminder to settle cash
/// - `DailySettlementSummary` → end-of-day summary
/// - `DepositConfirmed` → cash deposit confirmed
///
/// Client→Server: AcknowledgeAlert
class CashAlertHub {
  CashAlertHub({required TokenStorage tokenStorage})
      : _service = SignalRService(
          hubName: 'cash-alerts',
          tokenStorage: tokenStorage,
        );

  final SignalRService _service;

  void Function(Map<String, dynamic> data)? onCashThresholdExceeded;
  void Function(Map<String, dynamic> data)? onSettlementReminder;
  void Function(Map<String, dynamic> data)? onDailySettlementSummary;
  void Function(Map<String, dynamic> data)? onDepositConfirmed;

  Future<void> connect() async {
    await _service.connect();

    _service.on('CashThresholdExceeded', (args) {
      _handleEvent(args, onCashThresholdExceeded, 'CashThresholdExceeded');
    });

    _service.on('SettlementReminder', (args) {
      _handleEvent(args, onSettlementReminder, 'SettlementReminder');
    });

    _service.on('DailySettlementSummary', (args) {
      _handleEvent(args, onDailySettlementSummary, 'DailySettlementSummary');
    });

    _service.on('DepositConfirmed', (args) {
      _handleEvent(args, onDepositConfirmed, 'DepositConfirmed');
    });
  }

  void _handleEvent(
    List<Object?>? args,
    void Function(Map<String, dynamic>)? callback,
    String eventName,
  ) {
    if (args != null && args.isNotEmpty && callback != null) {
      try {
        final data = args[0] is String
            ? jsonDecode(args[0] as String) as Map<String, dynamic>
            : args[0] as Map<String, dynamic>;
        callback(data);
      } catch (e) {
        dev.log('Error parsing $eventName: $e', name: 'CashAlertHub');
      }
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    await _service.invoke('AcknowledgeAlert', args: [alertId]);
  }

  Future<void> disconnect() async {
    await _service.disconnect();
  }
}
