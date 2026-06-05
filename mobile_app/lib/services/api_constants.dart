import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      // 10.0.2.2 est l'adresse spéciale pour que l'émulateur Android 
      // accède au localhost de ton PC.
      return 'http://10.0.2.2:3000/api';
    }
  }
}
