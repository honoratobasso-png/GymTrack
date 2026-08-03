import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Controlador descartável do cronômetro exibido no painel de descanso.
class RestTimerController extends ChangeNotifier {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _initialSeconds = 60;
  int _remainingSeconds = 60;
  bool _isRunning = false;

  int get remainingSeconds => _remainingSeconds;
  int get initialSeconds => _initialSeconds;
  bool get isRunning => _isRunning;
  double get progress =>
      _initialSeconds == 0 ? 0 : _remainingSeconds / _initialSeconds;

  void startTimer(int seconds) {
    _timer?.cancel();
    _initialSeconds = seconds;
    _remainingSeconds = seconds;
    _isRunning = seconds > 0;
    notifyListeners();
    if (_isRunning) _startTicker();
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _remainingSeconds = 0;
        _onTimerFinished();
      } else {
        notifyListeners();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resumeTimer() {
    if (_remainingSeconds > 0 && !_isRunning) {
      _isRunning = true;
      notifyListeners();
      _startTicker();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _remainingSeconds = 0;
    notifyListeners();
  }

  Future<void> _onTimerFinished() async {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
    if (await Vibration.hasVibrator()) Vibration.vibrate(duration: 1000);
    // O player é mantido pronto para a adição do som configurável em versão futura.
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
