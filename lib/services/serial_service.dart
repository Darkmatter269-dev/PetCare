import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import '../models/alert.dart';
import '../models/alert_store.dart';

class SerialService {
  final AlertStore alertStore;
  UsbPort? _port;
  StreamSubscription<Uint8List>? _sub;
  String _buffer = '';
  Timer? _reconnectTimer;
  Timer? _simTimer;

  SerialService(this.alertStore);

  Future<void> start({bool enableSimulationIfNoDevice = true}) async {
    try {
      final devices = await UsbSerial.listDevices();
      if (devices.isEmpty) {
        if (enableSimulationIfNoDevice) _startSimulation();
        _scheduleReconnect();
        return;
      }

      final dev = devices.first;
      _port = await dev.create();
      final ok = await _port?.open();
      if (ok != true) {
        _scheduleReconnect();
        return;
      }
      // common settings — many Arduinos use 9600
      await _port?.setDTR(true);
      await _port?.setRTS(true);
      await _port?.setPortParameters(9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

      final input = _port?.inputStream;
      _sub = input?.listen(_onData, onError: _onError, onDone: _onDone, cancelOnError: true);
    } catch (e) {
      // fall back to simulation if desired
      if (enableSimulationIfNoDevice) _startSimulation();
      _scheduleReconnect();
    }
  }

  void _onData(Uint8List data) {
    try {
      final s = utf8.decode(data);
      _buffer += s;
      // split by newline
      while (_buffer.contains('\n')) {
        final idx = _buffer.indexOf('\n');
        final line = _buffer.substring(0, idx).trim();
        _buffer = _buffer.substring(idx + 1);
        if (line.isEmpty) continue;
        _handleLine(line);
      }
    } catch (e) {
      // ignore decoding errors
    }
  }

  void _handleLine(String line) {
    // Try JSON first
    try {
      final m = jsonDecode(line);
      if (m is Map) {
        final title = m['title']?.toString() ?? (m['type']?.toString() ?? 'Alert');
        final message = m['message']?.toString() ?? '';
        final tsStr = m['ts']?.toString() ?? m['timestamp']?.toString();
        final ts = tsStr != null ? DateTime.tryParse(tsStr) ?? DateTime.now() : DateTime.now();
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final alert = Alert(id: id, title: title, message: message, timestamp: ts);
        alertStore.addAlert(alert);
        return;
      }
    } catch (e) {
      // not JSON; fallback
    }

    // Fallback prefixed format: ALERT:TYPE|Message text|ts=...
    try {
      final parts = line.split('|');
      String title = 'Alert';
      String message = line;
      DateTime ts = DateTime.now();
      if (parts.isNotEmpty) {
        final first = parts[0];
        if (first.startsWith('ALERT:')) {
          final t = first.substring(6);
          title = t.replaceAll('_', ' ').splitMapJoin(RegExp(r'(.+)'), onMatch: (m) => m[0] ?? 'Alert');
        }
      }
      if (parts.length >= 2) message = parts[1];
      for (var p in parts) {
        if (p.contains('ts=')) {
          final v = p.split('ts=').last;
          final parsed = DateTime.tryParse(v);
          if (parsed != null) ts = parsed;
        }
      }
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final alert = Alert(id: id, title: title, message: message, timestamp: ts);
      alertStore.addAlert(alert);
    } catch (e) {
      // swallow
    }
  }

  void _onError(error) {
    _disposePort();
    _scheduleReconnect();
  }

  void _onDone() {
    _disposePort();
    _scheduleReconnect();
  }

  void _disposePort() {
    _sub?.cancel();
    _sub = null;
    try {
      _port?.close();
    } catch (_) {}
    _port = null;
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () => start());
  }

  void stop() {
    _reconnectTimer?.cancel();
    _simTimer?.cancel();
    _disposePort();
  }

  // Simple simulator for development: emits low-food/low-water alternately
  void _startSimulation() {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 12), (t) {
      final now = DateTime.now();
      final type = (t.tick % 2 == 0) ? 'Low Food Alert' : 'Low Water Alert';
      final msg = (t.tick % 2 == 0) ? 'Food level below threshold' : 'Water level below threshold';
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final alert = Alert(id: id, title: type, message: msg, timestamp: now);
      alertStore.addAlert(alert);
    });
  }
}
