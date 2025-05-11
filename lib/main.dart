import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'weather_service.dart';
import 'convert_to_grid.dart';
import 'dust_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: WeatherHomePage());
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String temperature = '';
  String humidity = '';
  String pm10 = '';
  String pm25 = '';
  String skyState = '';
  String ptyState = '';
  String errorMessage = '';
  String selectedRegion = '내 위치';

  final Map<String, Map<String, int>> regionGridMap = {
    '내 위치': {},
    '서울': {'nx': 60, 'ny': 127},
    '부산': {'nx': 98, 'ny': 76},
    '대구': {'nx': 89, 'ny': 90},
    '인천': {'nx': 55, 'ny': 124},
    '광주': {'nx': 58, 'ny': 74},
    '대전': {'nx': 67, 'ny': 100},
    '울산': {'nx': 102, 'ny': 84},
    '세종': {'nx': 66, 'ny': 103},
  };

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  void fetchAllData() async {
    setState(() {
      temperature = '';
      humidity = '';
      pm10 = '';
      pm25 = '';
      skyState = '';
      ptyState = '';
      errorMessage = '';
    });

    try {
      int nx, ny;
      String sido;

      if (selectedRegion == '내 위치') {
        await Permission.location.request();
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        final grid = convertToGrid(pos.latitude, pos.longitude);
        nx = grid['nx']!;
        ny = grid['ny']!;
        sido = '서울';
      } else {
        final coords = regionGridMap[selectedRegion]!;
        nx = coords['nx']!;
        ny = coords['ny']!;
        sido = selectedRegion;
      }

      final weather = await fetchWeatherData(nx: nx, ny: ny);
      final dust = await fetchDustData(sido);

      setState(() {
        temperature = weather['temperature']!;
        humidity = weather['humidity']!;
        skyState = getSkyText(weather['sky'] ?? '');
        ptyState = getPtyText(weather['pty'] ?? '');
        pm10 = dust['pm10']!;
        pm25 = dust['pm25']!;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  String getSkyText(String code) {
    switch (code) {
      case '1':
        return '맑음';
      case '3':
        return '구름 많음';
      case '4':
        return '흐림';
      default:
        return '정보 없음';
    }
  }

  String getPtyText(String code) {
    switch (code) {
      case '0':
        return '없음';
      case '1':
        return '비';
      case '2':
        return '비/눈';
      case '3':
        return '눈';
      case '4':
        return '소나기';
      default:
        return '정보 없음';
    }
  }

  Widget buildInfoRow(IconData icon, String label, String value, [String unit = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 8),
          Text('$label: $value$unit', style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('날씨 앱')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedRegion,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedRegion = value);
                  fetchAllData();
                }
              },
              items: regionGridMap.keys.map((region) {
                return DropdownMenuItem(value: region, child: Text(region));
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text('❌ 오류: $errorMessage', style: const TextStyle(color: Colors.red)),
            if (temperature.isNotEmpty && humidity.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoRow(Icons.thermostat, '기온', temperature, ' °C'),
                  buildInfoRow(Icons.water_drop, '습도', humidity, ' %'),
                  buildInfoRow(Icons.cloud, '하늘 상태', skyState),
                  buildInfoRow(Icons.umbrella, '강수 형태', ptyState),
                  buildInfoRow(Icons.cloud_queue, '미세먼지 (PM10)', pm10, ' ㎍/㎥'),
                  buildInfoRow(Icons.cloud_circle, '초미세먼지 (PM2.5)', pm25, ' ㎍/㎥'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
