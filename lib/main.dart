import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'weather_service.dart';
import 'convert_to_grid.dart';

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
  String errorMessage = '';
  String selectedRegion = '내 위치';

  final Map<String, Map<String, int>> regionGridMap = {
    '내 위치': {}, // GPS로 처리
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
    fetchWeather();
  }

  void fetchWeather() async {
    setState(() {
      temperature = '';
      humidity = '';
      errorMessage = '';
    });

    try {
      int nx, ny;

      if (selectedRegion == '내 위치') {
        await Permission.location.request();
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        final grid = convertToGrid(pos.latitude, pos.longitude);
        nx = grid['nx']!;
        ny = grid['ny']!;
      } else {
        final coords = regionGridMap[selectedRegion]!;
        nx = coords['nx']!;
        ny = coords['ny']!;
      }

      final data = await fetchWeatherData(nx: nx, ny: ny);
      setState(() {
        temperature = data['temperature']!;
        humidity = data['humidity']!;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
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
                  fetchWeather();
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
                children: [
                  Text('🌡 기온: $temperature °C', style: const TextStyle(fontSize: 24)),
                  Text('💧 습도: $humidity %', style: const TextStyle(fontSize: 24)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
