import 'dart:async';

class StreamManager<T> {
  final StreamController<T> _streamController = StreamController<T>();
  Stream<T> get stream => _streamController.stream;

  final Duration debounceTime;

  StreamManager([this.debounceTime = const Duration(milliseconds: 128)]);

  DateTime? _lastChangeDate;
  Timer? _timer;

  void addData(T data) {
    _lastChangeDate = DateTime.now();
    _streamController.add(data);
    _resetTimer();
  }

  _resetTimer() {
    _timer?.cancel();
    _timer = Timer(debounceTime, _checkIsStreamStale);
  }

  _checkIsStreamStale() {
    if (_lastChangeDate != null &&
        _lastChangeDate!.millisecond >= debounceTime.inMilliseconds) {
      _streamController.close();
      _timer?.cancel();
    }
  }
}
