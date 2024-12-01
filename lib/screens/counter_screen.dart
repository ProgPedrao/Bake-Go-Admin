import 'package:flutter/material.dart';
import 'package:bake_and_go_admin/providers/counter.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = CounterProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Exemplo contador",
        ),
      ),
      body: Column(
        children: [
          Text(provider!.state.value.toString()),
          IconButton(
            onPressed: () {
              setState(() {
                provider.state.inc();
              });
              // print(provider.state.value.toString());
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                provider.state.dec();
              });
              // print(provider.state.value.toString());
            },
            icon: const Icon(
              Icons.remove,
            ),
          ),
        ],
      ),
    );
  }
}
