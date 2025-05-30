export 'second_bloc.dart';

import 'package:call_detector_plugin/call_detector_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:call_detector_plugin_example/src/src.dart';

class SecondPage extends StatelessWidget with CallDetectorMixin {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecondBloc(
        callDetector: CallDetector(),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('SecondPage'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<SecondBloc, SecondState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  StreamBuilder(
                    stream: singletonCallDetectStream,
                    builder: (context, snapshot) {
                      return WText(
                        title: 'IsInCall: ',
                        subtitle: '${snapshot.data}',
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  WText(
                    title: 'Get current Call value: ',
                    subtitle: '${state.currentCallValue}',
                  ),
                  const SizedBox(height: 50),
                  TextButton(
                    onPressed: () {
                      context.read<SecondBloc>().add(SecondEvent.getCurrentCallStatus());
                    },
                    style: TextButton.styleFrom(backgroundColor: Colors.amber),
                    child: Text(
                      'Get current Call status',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              );
            },
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
