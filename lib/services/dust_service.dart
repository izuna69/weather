import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, String>> fetchDustData(String sido) async {
  const String serviceKey = 't%2FhBRyIamJhuAVC5SzI2Th5gsPlEaNNymYeEoeDtHWPw71H3otVavsztRJtteMXG8OgxnJAnSQhcc%2FbFmDrqNA%3D%3D'; // 니 토큰

  final url = Uri.parse(
    'https://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty'
        '?sidoName=$sido&returnType=JSON&serviceKey=$serviceKey&ver=1.0',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final item = jsonData['response']['body']['items'][0];

    return {
      'pm10': item['pm10Value'] ?? '-',
      'pm25': item['pm25Value'] ?? '-',
    };
  } else {
    throw Exception('미세먼지 정보를 가져오는 데 실패했습니다');
  }
}
