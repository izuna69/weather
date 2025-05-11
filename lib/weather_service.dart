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
        '&numOfRows=10&pageNo=1&dataType=JSON'
        '&base_date=$baseDate&base_time=$baseTime'
        '&nx=$nx&ny=$ny',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final items = jsonData['response']['body']['items']['item'];

    String temperature = '';
    String humidity = '';

    for (var item in items) {
      if (item['category'] == 'T1H') {
        temperature = item['obsrValue'];
      } else if (item['category'] == 'REH') {
        humidity = item['obsrValue'];
      }
    }

    return {
      'temperature': temperature,
      'humidity': humidity,
    };
  } else {
    throw Exception('날씨 데이터를 가져오는 데 실패했습니다');
  }
}
