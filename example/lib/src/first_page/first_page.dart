export 'first_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:call_detector_plugin_example/src/src.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FirstBloc(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('FirstPage'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<FirstBloc, FirstState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  WText(
                    title: 'IsInCall: ',
                    subtitle: '${state.isInCall}',
                  ),
                  const SizedBox(height: 20),
                  WText(
                    title: 'Get current Call value: ',
                    subtitle: '${state.currentCallValue}',
                  ),
                  const SizedBox(height: 50),
                  TextButton(
                    onPressed: () {
                      context.read<FirstBloc>().add(FirstEvent.getCurrentCallStatus());
                    },
                    style: TextButton.styleFrom(backgroundColor: Colors.amber),
                    child: Text(
                      'Get current Call status',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/second_page');
                    },
                    style: TextButton.styleFrom(backgroundColor: Colors.amber),
                    child: Text(
                      'Open SecondPage',
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

class WText extends StatelessWidget {
  final String title;
  final String subtitle;

  const WText({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      child: Text.rich(
        TextSpan(
          text: title,
          style: Theme.of(context).textTheme.headlineSmall,
          children: [
            TextSpan(
              text: subtitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
