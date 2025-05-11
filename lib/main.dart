import 'package:flutter/material.dart';
import 'weather_service.dart'; // 위 파일이 이 이름으로 저장됐다고 가정

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherHomePage(),
    );
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

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  void fetchWeather() async {
    try {
      final data = await fetchWeatherData();
      setState(() {
        temperature = data['temperature'] ?? '';
        humidity = data['humidity'] ?? '';
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
      appBar: AppBar(title: const Text('현재 날씨')),
      body: Center(
        child: errorMessage.isNotEmpty
            ? Text('오류: $errorMessage')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('기온: $temperature °C', style: const TextStyle(fontSize: 24)),
            Text('습도: $humidity %', style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
