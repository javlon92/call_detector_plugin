part of 'second_bloc.dart';

sealed class SecondEvent with EquatableMixin {
  const SecondEvent();

  const factory SecondEvent.getCurrentCallStatus() = _GetCurrentCallStatus;
}

final class _GetCurrentCallStatus extends SecondEvent {
  const _GetCurrentCallStatus();

  @override
  List<Object?> get props => [];
}
