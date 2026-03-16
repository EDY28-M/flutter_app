import 'package:flutter/foundation.dart';

class AppConfig {
  static const String googleWebClientId =
      '519429005769-ta2fpa67mjtnh7f8ebqieardk9d0enpl.apps.googleusercontent.com';

  static const String googleAndroidClientId =
      '519429005769-fi75lsml0l0ohhu5s1e0ucfs1ijheh54.apps.googleusercontent.com';

  /// Emulador: 10.0.2.2 es localhost de tu PC
  static const String apiBaseUrlEmulator = 'http://10.0.2.2:3000';

  /// Dispositivo real: IP de tu PC en la red local
  static const String apiBaseUrlDevice = 'http://172.16.0.5:3000';

  /// ngrok: URL pública para que cualquiera se conecte (sin estar en tu red)
  /// 1. Pon useNgrok = true
  /// 2. Pega tu URL de ngrok en apiBaseUrlNgrok (cambia cada vez que reinicias ngrok)
  static const bool useNgrok = false;
  static const String apiBaseUrlNgrok = 'https://8f83-190-43-252-228.ngrok-free.app';

  /// Prioridad: ngrok > emulador/dispositivo
  static String get apiBaseUrl =>
      useNgrok ? apiBaseUrlNgrok : (kDebugMode ? apiBaseUrlEmulator : apiBaseUrlDevice);
}
