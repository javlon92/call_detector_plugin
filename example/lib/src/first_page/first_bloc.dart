import 'dart:async';
import 'package:call_detector_plugin/call_detector_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:call_detector_plugin_example/src/src.dart';

part 'first_event.dart';

part 'first_state.dart';

class FirstBloc extends Bloc<FirstEvent, FirstState> with CallDetectorMixin {
  FirstBloc() : super(const FirstState()) {
    on<_WatchDetector>(_watchDetector);
    on<_GetCurrentCallStatus>(_getCurrentCallStatus);

    add(_WatchDetector());
  }

  Future<void> _watchDetector(_WatchDetector event, Emitter<FirstState> emit) {
    return emit.forEach(
      callDetectStream,
      onData: (callStatus) => state.copyWith(isInCall: callStatus),
    );
  }

  Future<void> _getCurrentCallStatus(_GetCurrentCallStatus event, Emitter<FirstState> emit) async {
    emit(state.copyWith(getCurrentCallStatus: Status.loading));

    final currentCallValue = await getCurrentCallStatus();

    emit(state.copyWith(currentCallValue: currentCallValue, getCurrentCallStatus: Status.success));
  }
}
