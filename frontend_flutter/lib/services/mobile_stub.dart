// Stub file for mobile TTS when running on web
// This file provides empty implementations for mobile-only imports

class FlutterTts {
  FlutterTts();
  
  Future<void> setLanguage(String language) async {}
  Future<void> setPitch(double pitch) async {}
  Future<void> setSpeechRate(double rate) async {}
  Future<void> setVolume(double volume) async {}
  
  void setCompletionHandler(Function callback) {}
  void setErrorHandler(Function callback) {}
  void setStartHandler(Function callback) {}
  
  Future<void> speak(String text) async {}
  Future<void> stop() async {}
  Future<void> pause() async {}
  
  Future<List<dynamic>> get getVoices async => [];
}
