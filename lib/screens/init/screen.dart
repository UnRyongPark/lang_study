import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InitScreen extends StatelessWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('This is Init Screen'),
      ),
      body: Column(
        children: [
          Text('This is Init Screen'),
          ElevatedButton(
            onPressed: () {
              context.go('/stt');
            },
            child: const Text('음성 인식 데모'),
          ),
        ],
      ),
    );
  }
}
