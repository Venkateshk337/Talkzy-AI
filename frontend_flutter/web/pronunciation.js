// Web Speech API implementation for pronunciation
window.speechSynthesis.getVoices();

// Initialize pronunciation functions
window.speakText = function(text) {
  if (!window.speechSynthesis) {
    console.error("Speech not supported");
    return false;
  }

  // Cancel any ongoing speech
  window.speechSynthesis.cancel();

  const speech = new SpeechSynthesisUtterance(text);

  // Configure speech settings
  speech.lang = "en-US";
  speech.rate = 0.9;
  speech.pitch = 1;

  // Select best English voice
  const voices = window.speechSynthesis.getVoices();
  if (voices.length > 0) {
    speech.voice = voices.find(v => v.lang.includes("en")) || voices[0];
  }

  // Error handling
  speech.onerror = function(e) {
    console.error("Pronunciation error:", e);
    return false;
  };

  // Start speaking
  window.speechSynthesis.speak(speech);
  return true;
};

window.stopSpeech = function() {
  if (window.speechSynthesis) {
    window.speechSynthesis.cancel();
    return true;
  }
  return false;
};

window.pauseSpeech = function() {
  if (window.speechSynthesis) {
    window.speechSynthesis.pause();
    return true;
  }
  return false;
};

window.resumeSpeech = function() {
  if (window.speechSynthesis) {
    window.speechSynthesis.resume();
    return true;
  }
  return false;
};
