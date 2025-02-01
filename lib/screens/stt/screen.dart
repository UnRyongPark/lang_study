import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// stt 패키지를 활용한 음성 인식 데모 화면입니다.
/// 상태 관리는 riverpod을 사용하며 StatefulWidget 대신 ConsumerWidget을 사용합니다.
final _sttProvider = StateNotifierProvider<SttNotifier, SttState>(
  (ref) {
    final sttNotifier = SttNotifier();
    sttNotifier.init();
    return sttNotifier;
  },
);

class SttScreen extends ConsumerWidget {
  const SttScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sttState = ref.watch(_sttProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
        title: const Text('STT 데모'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(_sttProvider.notifier).init();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '음성 인식 결과:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  sttState.text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(_sttProvider.notifier).toggleListening();
              },
              child: Text(sttState.isListening ? '듣기 중지' : '듣기 시작'),
            ),
          ],
        ),
      ),
    );
  }
}

class SttState {
  final bool isListening;
  final String text;
  final bool isAvailable;

  const SttState(
      {this.isListening = false, this.text = '', this.isAvailable = false});

  SttState copyWith({bool? isListening, String? text, bool? isAvailable}) {
    return SttState(
      isListening: isListening ?? this.isListening,
      text: text ?? this.text,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class SttNotifier extends StateNotifier<SttState> {
  SttNotifier() : super(const SttState()) {
    _stt = SpeechToText();
  }

  late final SpeechToText _stt;

  Future<void> init() async {
    print('init');
    bool isAvailable = await _stt.initialize();
    print('isAvailable: $isAvailable');
    if (!isAvailable) {
      state = state.copyWith(text: '음성 인식을 사용할 수 없습니다.', isAvailable: false);
    } else {
      state = state.copyWith(isAvailable: true);
    }
  }

  /// 음성 듣기를 시작하거나 중지합니다.
  Future<void> toggleListening() async {
    if (!state.isAvailable) {
      return;
    }

    if (state.isListening) {
      await _stt.stop();
      state = state.copyWith(isListening: false);
    } else {
      state = state.copyWith(text: '');
      await _stt.listen(
        onResult: _onResult,
      );
      state = state.copyWith(isListening: true);
    }
  }

  /// 음성 인식 콜백 함수로 결과를 업데이트합니다.
  void _onResult(SpeechRecognitionResult result) {
    state = state.copyWith(text: result.recognizedWords);
    if (result.finalResult) {
      stopListening();
    }
  }

  /// 듣기를 중지합니다.
  Future<void> stopListening() async {
    await _stt.stop();
    state = state.copyWith(isListening: false);
  }
}
