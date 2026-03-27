import 'dart:developer' as dev;
import 'package:signalr_netcore/signalr_client.dart';
import '../storage/token_storage.dart';

/// Base SignalR service for connecting to Sekka hubs.
class SignalRService {
  SignalRService({
    required String hubName,
    required TokenStorage tokenStorage,
  })  : _hubName = hubName,
        _tokenStorage = tokenStorage;

  final String _hubName;
  final TokenStorage _tokenStorage;
  HubConnection? _connection;

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  Future<void> connect() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return;

    final url = 'https://sekka.runasp.net/hubs/$_hubName?access_token=$token';

    _connection = HubConnectionBuilder()
        .withUrl(url)
        .withAutomaticReconnect()
        .build();

    _connection!.onclose(({error}) {
      dev.log('SignalR [$_hubName] disconnected: $error', name: 'SignalR');
    });

    _connection!.onreconnecting(({error}) {
      dev.log('SignalR [$_hubName] reconnecting: $error', name: 'SignalR');
    });

    _connection!.onreconnected(({connectionId}) {
      dev.log('SignalR [$_hubName] reconnected: $connectionId', name: 'SignalR');
    });

    try {
      await _connection!.start();
      dev.log('SignalR [$_hubName] connected', name: 'SignalR');
    } catch (e) {
      dev.log('SignalR [$_hubName] connection failed: $e', name: 'SignalR');
    }
  }

  void on(String methodName, void Function(List<Object?>?) callback) {
    _connection?.on(methodName, callback);
  }

  Future<void> invoke(String methodName, {List<Object>? args}) async {
    if (!isConnected) return;
    await _connection?.invoke(methodName, args: args);
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }
}
