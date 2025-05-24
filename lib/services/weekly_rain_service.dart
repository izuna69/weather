import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyRainForecast {
  final DateTime date;
  final bool willRain;

  DailyRainForecast({required this.date, required this.willRain});
}

Future<List<DailyRainForecast>> fetchWeeklyRainForecast({required int nx, required int ny}) async {
  const String serviceKey = 't%2FhBRyIamJhuAVC5SzI2Th5gsPlEaNNymYeEoeDtHWPw71H3otVavsztRJtteMXG8OgxnJAnSQhcc%2FbFmDrqNA%3D%3D';
  final now = DateTime.now();
  final List<DailyRainForecast> results = [];

  for (int i = 0; i < 8; i++) {
    final date = now.add(Duration(days: i));
    final baseDate = "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
    final baseTime = "0500"; // 단기예보는 보통 0500시 기준 사용

    final url = Uri.parse(
      'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst'
          '?serviceKey=$serviceKey&numOfRows=1000&pageNo=1&dataType=JSON'
          '&base_date=$baseDate&base_time=$baseTime&nx=$nx&ny=$ny',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final items = jsonData['response']?['body']?['items']?['item'] ?? [];

      final ptyList = items.where((item) => item['category'] == 'PTY').toList();
      final willRain = ptyList.any((item) => item['fcstValue'] != '0');

      results.add(DailyRainForecast(date: date, willRain: willRain));
    } else {
      throw Exception('[$baseDate] 예보 데이터를 불러오지 못했습니다');
    }
  }

  return results;
}
