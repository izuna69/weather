import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, String>> fetchWeatherData() async {
  const String serviceKey = 't%2FhBRyIamJhuAVC5SzI2Th5gsPlEaNNymYeEoeDtHWPw71H3otVavsztRJtteMXG8OgxnJAnSQhcc%2FbFmDrqNA%3D%3D';
  const String baseDate = '20250511'; // 오늘 날짜
  const String baseTime = '1100'; // 11:00 발표 (현재 시각 기준으로 조절 필요)
  const String nx = '60'; // 서울 종로구 기준
  const String ny = '127';

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
