import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'state.dart';

enum SpeakResult { ok, noVoice, error }

/// Membacakan teks dengan suara milik perangkat (offline selama paket suara
/// bahasa itu sudah terpasang di HP).
class Speaker {
  static final FlutterTts _tts = FlutterTts();
  static final ValueNotifier<bool> speaking = ValueNotifier<bool>(false);
  static bool _ready = false;

  static void _init() {
    if (_ready) return;
    _ready = true;
    _tts.setStartHandler(() => speaking.value = true);
    _tts.setCompletionHandler(() => speaking.value = false);
    _tts.setErrorHandler((message) => speaking.value = false);
    // Pembatalan karena bacaan baru dimulai tidak boleh mematikan indikator.
    _tts.setCancelHandler(() {});
    _tts.setSpeechRate(0.45);
  }

  static Future<bool> hasVoice(Lang lang) async {
    try {
      final r = await _tts.isLanguageAvailable(lang.ttsCode);
      return r == true || r == 1;
    } catch (_) {
      return false;
    }
  }

  static Future<SpeakResult> speak(String text, Lang lang) async {
    _init();
    try {
      if (!await hasVoice(lang)) return SpeakResult.noVoice;
      await _tts.stop();
      await _tts.setLanguage(lang.ttsCode);
      speaking.value = true;
      await _tts.speak(text);
      return SpeakResult.ok;
    } catch (_) {
      speaking.value = false;
      return SpeakResult.error;
    }
  }

  static Future<void> stop() async {
    speaking.value = false;
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
