part of 'first_bloc.dart';

class FirstState extends Equatable {
  final Status getCurrentCallStatus;
  final bool currentCallValue;
  final bool isInCall;

  const FirstState({
    this.getCurrentCallStatus = Status.initial,
    this.isInCall = false,
    this.currentCallValue = false,
  });

  FirstState copyWith({
    Status? getCurrentCallStatus,
    Status? getPlatformVersionStatus,
    bool? isInCall,
    bool? currentCallValue,
    String? platformVersion,
  }) {
    return FirstState(
      getCurrentCallStatus: getCurrentCallStatus ?? this.getCurrentCallStatus,
      isInCall: isInCall ?? this.isInCall,
      currentCallValue: currentCallValue ?? this.currentCallValue,
    );
  }

  @override
  List<Object> get props => [
        isInCall,
        currentCallValue,
        getCurrentCallStatus,
      ];
}
