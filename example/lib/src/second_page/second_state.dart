part of 'second_bloc.dart';

class SecondState extends Equatable {
  final Status getCurrentCallStatus;
  final Status getPlatformVersionStatus;
  final bool currentCallValue;
  final String platformVersion;

  const SecondState({
    this.getCurrentCallStatus = Status.initial,
    this.getPlatformVersionStatus = Status.initial,
    this.currentCallValue = false,
    this.platformVersion = 'unknown',
  });

  SecondState copyWith({
    Status? getCurrentCallStatus,
    Status? getPlatformVersionStatus,
    bool? isInCall,
    bool? currentCallValue,
    String? platformVersion,
  }) {
    return SecondState(
      getCurrentCallStatus: getCurrentCallStatus ?? this.getCurrentCallStatus,
      getPlatformVersionStatus: getPlatformVersionStatus ?? this.getPlatformVersionStatus,
      currentCallValue: currentCallValue ?? this.currentCallValue,
      platformVersion: platformVersion ?? this.platformVersion,
    );
  }

  @override
  List<Object> get props => [
        currentCallValue,
        platformVersion,
        getCurrentCallStatus,
        getPlatformVersionStatus,
      ];
}
