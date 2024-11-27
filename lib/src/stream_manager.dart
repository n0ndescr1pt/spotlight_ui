import 'dart:async';

class StreamManager<T> {
  final StreamController<T> _streamController = StreamController<T>();
  Stream<T> get stream => _streamController.stream;

  final Duration debaunceTime;

  StreamManager([this.debaunceTime = const Duration(milliseconds: 128)]);

  DateTime? _lastChangeDate;
  Timer? _timer;

  void addData(T data) {
    _lastChangeDate = DateTime.now();
    _streamController.add(data);
    _resetTimer();
  }

  _resetTimer() {
    _timer?.cancel();
    _timer = Timer(debaunceTime, _checkIsStreamStale);
  }

  _checkIsStreamStale() {
    if (_lastChangeDate != null &&
        _lastChangeDate!.millisecond >= debaunceTime.inMilliseconds) {
      _streamController.close();
      _timer?.cancel();
    }
  }
}
