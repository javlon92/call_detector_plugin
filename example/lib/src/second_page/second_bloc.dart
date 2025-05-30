import 'dart:async';
import 'package:call_detector_plugin/call_detector_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:call_detector_plugin_example/src/src.dart';

part 'second_event.dart';

part 'second_state.dart';

class SecondBloc extends Bloc<SecondEvent, SecondState> {
  final CallDetector callDetector;

  SecondBloc({
    required this.callDetector,
  }) : super(const SecondState()) {
    on<_GetCurrentCallStatus>(_getCurrentCallStatus);
  }

  Future<void> _getCurrentCallStatus(_GetCurrentCallStatus event, Emitter<SecondState> emit) async {
    emit(state.copyWith(getCurrentCallStatus: Status.loading));

    final currentCallValue = await callDetector.getCurrentCallStatus();

    emit(state.copyWith(currentCallValue: currentCallValue, getCurrentCallStatus: Status.success));
  }
}
