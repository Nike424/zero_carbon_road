import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math';

class StepService {
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;
  int _todaySteps = 0;
  DateTime _lastResetDate = DateTime.now();
  final Random _random = Random();

  final StreamController<int> _stepController =
      StreamController<int>.broadcast();
  Stream<int> get stepStream => _stepController.stream;
  int get todaySteps => _todaySteps;

  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  void startListening() {
    _checkAndResetSteps();
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountSubscription = _stepCountStream?.listen(
      (StepCount event) {
        _checkAndResetSteps();
        _todaySteps = event.steps;
        _stepController.add(_todaySteps);
      },
      onError: (error) {
        print('步数传感器不可用，使用模拟数据');
        _useMockStepData();
      },
    );
  }

  void _useMockStepData() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkAndResetSteps();
      _todaySteps += _random.nextInt(50) + 30;
      _stepController.add(_todaySteps);
    });
  }

  void _checkAndResetSteps() {
    final now = DateTime.now();
    if (now.day != _lastResetDate.day ||
        now.month != _lastResetDate.month ||
        now.year != _lastResetDate.year) {
      _todaySteps = 0;
      _lastResetDate = now;
    }
  }

  void stopListening() {
    _stepCountSubscription?.cancel();
  }

  void dispose() {
    _stepController.close();
    stopListening();
  }
}
