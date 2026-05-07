// Central place to configure the API base URL and constants.
// Change baseUrl to your local machine's IP when running on a real device.
import 'package:flutter/foundation.dart';

class AppConstants {
  static String get _host => kIsWeb ? '127.0.0.1:8081' : '127.0.0.1:8081';

  static String get baseUrl => 'http://$_host/api';
  static String get uploadBaseUrl => 'http://$_host';
  static const String tokenKey = 'jwt_token';
  static const String roleKey = 'user_role';
  static const int lowStockThreshold = 5;
}
