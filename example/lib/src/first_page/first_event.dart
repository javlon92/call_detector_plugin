part of 'first_bloc.dart';

sealed class FirstEvent with EquatableMixin {
  const FirstEvent();

  const factory FirstEvent.getCurrentCallStatus() = _GetCurrentCallStatus;
}

final class _WatchDetector extends FirstEvent {
  const _WatchDetector();

  @override
  List<Object> get props => [];
}

final class _GetCurrentCallStatus extends FirstEvent {
  const _GetCurrentCallStatus();

  @override
  List<Object?> get props => [];
}
