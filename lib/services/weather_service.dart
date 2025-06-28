import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ✅ SharedPreferences 직접 사용
import '../models/hourly_forecast.dart';
import '../utils/region_grid_map.dart';

Future<Map<String, String>> fetchWeatherData({required int nx, required int ny}) async {
  const String serviceKey = 't%2FhBRyIamJhuAVC5SzI2Th5gsPlEaNNymYeEoeDtHWPw71H3otVavsztRJtteMXG8OgxnJAnSQhcc%2FbFmDrqNA%3D%3D'; //토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰토큰
  final DateTime now = DateTime.now();

  final cutoff = now.subtract(const Duration(minutes: 45));
  final adjusted = cutoff.subtract(const Duration(hours: 1));

  String baseDate = "${adjusted.year}${adjusted.month.toString().padLeft(2, '0')}${adjusted.day.toString().padLeft(2, '0')}";
  String baseTime = "${adjusted.hour.toString().padLeft(2, '0')}00";

  final Uri url = Uri.parse(
    'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
        '?serviceKey=$serviceKey'
        '&numOfRows=100&pageNo=1&dataType=JSON'
        '&base_date=$baseDate&base_time=$baseTime'
        '&nx=$nx&ny=$ny',
  );

  print("📡 날씨 실황 요청 URL: $url");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final items = jsonData['response']?['body']?['items']?['item'];

    if (items == null) {
      print("⚠️ 응답 본문: ${response.body}");
      throw Exception('데이터가 비어 있습니다 (items가 null)');
    }

    String temperature = '';
    String humidity = '';
    String pty = '';
    String sky = '';

    for (var item in items) {
      switch (item['category']) {
        case 'T1H':
          temperature = item['obsrValue'];
          break;
        case 'REH':
          humidity = item['obsrValue'];
          break;
        case 'PTY':
          pty = item['obsrValue'];
          break;
        case 'SKY':
          sky = item['obsrValue'];
          break;
      }
    }

    // ✅ 위젯용 요약 문자열 저장
    final prefs = await SharedPreferences.getInstance();
    final summary = "온도: $temperature°C\n습도: $humidity%\n하늘: ${skyStatus(sky)}\n강수: ${ptyStatus(pty)}";
    await prefs.setString('widget_weather', summary);

    return {
      'temperature': temperature,
      'humidity': humidity,
      'pty': pty,
      'sky': sky,
    };
  } else {
    print("❌ 응답 실패: statusCode=${response.statusCode}, body=${response.body}");
    throw Exception('날씨 정보를 가져오지 못했습니다 (status code: ${response.statusCode})');
  }
}

Future<List<HourlyForecast>> fetchHourlyForecast({required int nx, required int ny}) async {
  const String serviceKey = 't%2FhBRyIamJhuAVC5SzI2Th5gsPlEaNNymYeEoeDtHWPw71H3otVavsztRJtteMXG8OgxnJAnSQhcc%2FbFmDrqNA%3D%3D';
  final now = DateTime.now();

  final cutoff = now.subtract(const Duration(minutes: 45));
  final adjusted = cutoff.subtract(const Duration(hours: 1));

  final baseDate = "${adjusted.year}${adjusted.month.toString().padLeft(2, '0')}${adjusted.day.toString().padLeft(2, '0')}";
  final baseTime = "${adjusted.hour.toString().padLeft(2, '0')}30";

  final url = Uri.parse(
    'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
        '?serviceKey=$serviceKey&numOfRows=100&pageNo=1&dataType=JSON'
        '&base_date=$baseDate&base_time=$baseTime&nx=$nx&ny=$ny',
  );

  print("예보 요청 디버깅용 URL: $url");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final items = jsonData['response']?['body']?['items']?['item'];

    if (items == null) {
      print("⚠️ 시간별 응답 본문: ${response.body}");
      throw Exception('시간별 예보 데이터가 비어 있습니다');
    }

    final Map<String, Map<String, String>> grouped = {};

    for (var item in items) {
      final time = item['fcstTime'];
      final category = item['category'];
      final value = item['fcstValue'];

      if (category == 'SKY' || category == 'PTY') {
        grouped.putIfAbsent(time, () => {});
        grouped[time]![category] = value;
      }
    }

    return grouped.entries.map((e) {
      final time = e.key;
      final sky = e.value['SKY'] ?? '0';
      final pty = e.value['PTY'] ?? '0';
      return HourlyForecast(time: time, sky: sky, pty: pty);
    }).toList();
  } else {
    print("❌ 시간별 예보 실패: statusCode=${response.statusCode}, body=${response.body}");
    throw Exception('시간별 예보를 가져오지 못했습니다');
  }
}

String skyStatus(String code) {
  switch (code) {
    case '1': return '맑음';
    case '3': return '구름 많음';
    case '4': return '흐림';
    default: return '정보 없음';
  }
}

String ptyStatus(String code) {
  switch (code) {
    case '0': return '없음';
    case '1': return '비';
    case '2': return '비/눈';
    case '3': return '눈';
    case '4': return '소나기';
    default: return '정보 없음';
  }
}
