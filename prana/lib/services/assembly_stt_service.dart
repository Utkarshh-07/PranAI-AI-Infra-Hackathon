import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_keys.dart';

class AssemblySttService {
  final AudioRecorder _recorder = AudioRecorder();
  WebSocketChannel? _channel;
  StreamSubscription<Uint8List>? _audioSub;
  StreamSubscription? _socketSub;

  bool _isListening = false;
  bool get isListening => _isListening;

  // AssemblyAI requires 50–1000ms of audio per message.
  // At 16kHz mono PCM16: 16000 samples/sec × 2 bytes = 32000 bytes/sec.
  // 3200 bytes = 100ms — comfortably inside the valid range.
  static const int _chunkBytes = 3200;
  final BytesBuilder _audioBuffer = BytesBuilder();

  Function(String finalText)? onFinalTranscript;
  Function(String partialText)? onPartialTranscript;
  Function(String error)? onError;

  Future<void> startListening() async {
    if (_isListening) return;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      onError?.call('Microphone permission denied');
      return;
    }

    final uri = Uri.parse(
      'wss://streaming.assemblyai.com/v3/ws?sample_rate=16000&format_turns=true',
    );

    try {
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {'Authorization': ApiKeys.assemblyAI},
      );
    } catch (e) {
      onError?.call('Could not connect to AssemblyAI: $e');
      return;
    }

    _isListening = true;
    _audioBuffer.clear();

    _socketSub = _channel!.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          final type = data['type'];

          if (type == 'Turn') {
            final transcript = (data['transcript'] ?? '') as String;
            final endOfTurn = data['end_of_turn'] == true;

            if (endOfTurn && transcript.trim().isNotEmpty) {
              onFinalTranscript?.call(transcript.trim());
            } else {
              onPartialTranscript?.call(transcript);
            }
          } else if (type == 'Error') {
            onError?.call(data['error']?.toString() ?? 'AssemblyAI error');
          }
        } catch (e) {
          print('⚠️ Could not parse AssemblyAI message: $e');
        }
      },
      onError: (e) {
        onError?.call('WebSocket error: $e');
        stopListening();
      },
      onDone: () {
        _isListening = false;
      },
    );

    final audioStream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    _audioSub = audioStream.listen((chunk) {
      if (!_isListening || _channel == null) return;

      // Buffer incoming audio, then emit fixed-size chunks that
      // satisfy AssemblyAI's 50–1000ms duration requirement.
      _audioBuffer.add(chunk);

      while (_audioBuffer.length >= _chunkBytes) {
        final buffered = _audioBuffer.takeBytes();
        final toSend = Uint8List.sublistView(buffered, 0, _chunkBytes);
        _channel!.sink.add(toSend);

        // Keep whatever is left over for the next round.
        if (buffered.length > _chunkBytes) {
          _audioBuffer.add(Uint8List.sublistView(buffered, _chunkBytes));
        }
      }
    });
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;

    await _audioSub?.cancel();
    _audioSub = null;
    await _recorder.stop();
    _audioBuffer.clear();

    await _socketSub?.cancel();
    _socketSub = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    stopListening();
    _recorder.dispose();
  }
}