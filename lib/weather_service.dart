import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, String>> fetchWeatherData({required int nx, required int ny}) async {
  const String serviceKey = 't%2FhBRyIamJhuAVC5SzI2Th5gsPlEaNNymYeEoeDtHWPw71H3otVavsztRJtteMXG8OgxnJAnSQhcc%2FbFmDrqNA%3D%3D';
  final DateTime now = DateTime.now();

  String baseDate = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
  String baseTime = now.hour < 2 ? "0000" : "${(now.hour - 1).toString().padLeft(2, '0')}00";

  final Uri url = Uri.parse(
    'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
        '?serviceKey=$serviceKey'
        '&numOfRows=100&pageNo=1&dataType=JSON'
        '&base_date=$baseDate&base_time=$baseTime'
        '&nx=$nx&ny=$ny',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final items = jsonData['response']['body']['items']['item'];

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

    return {
      'temperature': temperature,
      'humidity': humidity,
      'pty': pty,
      'sky': sky,
    };
  } else {
    throw Exception('날씨 정보를 가져오지 못했습니다');
  }
}