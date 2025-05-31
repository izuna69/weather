import 'package:flutter/services.dart';

Future<void> refreshAndroidWidget() async {
  const platform = MethodChannel('com.example.weather_clean_fixed/widget');
  try {
    await platform.invokeMethod('refresh');
  } catch (e) {
    print('🔁 위젯 새로고침 실패: $e');
  }
}
