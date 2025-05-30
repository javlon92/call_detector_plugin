import 'dart:async';
import 'dart:collection';

/// A simple mutex (mutual exclusion) implementation.
/// Ensures that only one task can execute the critical section at a time.
class Mutex {
  /// Queue of completers representing tasks waiting for the mutex.
  final Queue<Completer<void>> _queue = Queue<Completer<void>>();

  /// Checks if the mutex is currently locked.
  bool get isLocked => _queue.isNotEmpty;

  /// Returns the number of tasks currently waiting for the lock.
  int get tasks => _queue.length;

  /// Locks the mutex and returns a Future that completes when the lock is acquired.
  Future<void> lock() {
    final completer = Completer<void>();
    final previous = _queue.isEmpty ? null : _queue.last;
    _queue.add(completer);

    if (previous == null || previous.isCompleted) {
      completer.complete(); // First task in queue proceeds immediately
    }

    return completer.future;
  }

  /// Unlocks the mutex, allowing the next waiting task (if any) to proceed.
  void unlock() {
    while (_queue.isNotEmpty) {
      final completer = _queue.removeFirst();
      if (!completer.isCompleted) {
        completer.complete();
        break;
      }
    }
  }

  /// Runs a function exclusively and returns its result.
  Future<T> synchronize<T>(Future<T> Function() action) async {
    await lock();
    try {
      return await action();
    } finally {
      unlock();
    }
  }
}

/*
void main() async {
  final mutex = Mutex();

  Future<String> criticalSection(int id) async {
    print(Task $id is in the critical section);
    await Future.delayed(const Duration(milliseconds: 500));
    print(Task $id is leaving the critical section);
    return 'Result from task $id';
  }

  final futures = List.generate(5, (i) {
    return mutex.synchronize(() => criticalSection(i));
  });


  final results = await Future.wait(futures);
  print('All results: $results');
}
*/
