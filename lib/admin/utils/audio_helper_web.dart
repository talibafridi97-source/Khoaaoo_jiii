// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void playAudioAlert() {
  try {
    final audio = html.AudioElement('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3');
    audio.volume = 1.0;
    audio.play();
  } catch (e) {
    // ignore autoplay restrictions
  }
}
