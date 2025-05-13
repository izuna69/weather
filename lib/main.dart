import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'weather_service.dart' show fetchWeatherData, fetchHourlyForecast, HourlyForecast;
import 'convert_to_grid.dart';
import 'dust_service.dart' show fetchDustData;
import 'drawer_menu.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: WeatherHomePage(), debugShowCheckedModeBanner: false);
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> with SingleTickerProviderStateMixin {
  String temperature = '';
  String humidity = '';
  String pm10 = '';
  String pm25 = '';
  String skyState = '';
  String ptyState = '';
  String errorMessage = '';
  String currentTime = '';
  String selectedRegion = '내 위치';

  List<String> savedRegions = [];
  List<HourlyForecast> hourlyForecasts = [];

  Timer? _timer;
  bool weatherVisible = false;
  bool errorVisible = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    setState(() {
      currentTime = formatter.format(now);
    });
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
      weatherVisible = false;
      errorVisible = false;
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
        final coords = regionGridMap[selectedRegion];
        if (coords == null) throw Exception('해당 지역은 지원되지 않습니다.');
        nx = coords['nx']!;
        ny = coords['ny']!;
        sido = selectedRegion;
      }

      final weather = await fetchWeatherData(nx: nx, ny: ny);
      final dust = await fetchDustData(sido);
      final hourly = await fetchHourlyForecast(nx: nx, ny: ny);

      setState(() {
        temperature = weather['temperature']!;
        humidity = weather['humidity']!;
        skyState = getSkyText(weather['sky'] ?? '');
        ptyState = getPtyText(weather['pty'] ?? '');
        pm10 = dust['pm10']!;
        pm25 = dust['pm25']!;
        hourlyForecasts = hourly;
        weatherVisible = true;
        _controller.forward(from: 0);
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        errorVisible = true;
      });
    }
  }

  void onRegionAdded(String region) {
    if (!savedRegions.contains(region)) {
      setState(() {
        savedRegions.add(region);
      });
    }
  }

  void onRegionSelected(String region) {
    if (regionGridMap.containsKey(region)) {
      setState(() {
        selectedRegion = region;
      });
      fetchAllData();
    } else {
      setState(() {
        errorMessage = '지원되지 않는 지역입니다: $region';
        errorVisible = true;
      });
    }
  }

  String getSkyText(String code) {
    switch (code) {
      case '1': return '맑음';
      case '3': return '구름 많음';
      case '4': return '흐림';
      default: return '정보 없음';
    }
  }

  String getPtyText(String code) {
    switch (code) {
      case '0': return '없음';
      case '1': return '비';
      case '2': return '비/눈';
      case '3': return '눈';
      case '4': return '소나기';
      default: return '정보 없음';
    }
  }

  String getDustComment(String pm10Value) {
    int value = int.tryParse(pm10Value) ?? 0;
    if (value <= 30) return "미세먼지가 좋아요. 산책해도 괜찮아요.";
    if (value <= 80) return "오늘은 보통이에요. 마스크는 선택입니다.";
    return "미세먼지가 안좋아 마스크를 쓰는 걸 추천해요.";
  }

  String getDustGrade(String pm10Value) {
    int value = int.tryParse(pm10Value) ?? 0;
    if (value <= 30) return "좋음";
    if (value <= 80) return "보통";
    if (value <= 150) return "나쁨";
    return "매우나쁨";
  }

  Color getDustColor(String grade) {
    switch (grade) {
      case '좋음': return Colors.blue;
      case '보통': return Colors.green;
      case '나쁨': return Colors.orange;
      case '매우나쁨': return Colors.red;
      default: return Colors.white;
    }
  }

  IconData getWeatherIcon(String sky, String pty) {
    if (pty == '1') return Icons.umbrella;
    if (pty == '2' || pty == '3') return Icons.ac_unit;
    if (pty == '4') return Icons.grain;

    switch (sky) {
      case '1': return Icons.wb_sunny;
      case '3': return Icons.cloud_queue;
      case '4': return Icons.cloud;
      default: return Icons.help_outline;
    }
  }

  Widget buildInfoRow(IconData icon, String label, String value, [String unit = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(width: 8),
          Text('$label: $value$unit', style: const TextStyle(fontSize: 20, color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dustGrade = getDustGrade(pm10);
    final dustColor = getDustColor(dustGrade);

    return Scaffold(
      backgroundColor: Colors.lightBlue[300],
      appBar: AppBar(
        title: const Text('WEATHER'),
        backgroundColor: Colors.lightBlue[300],
        elevation: 0,
      ),
      drawer: DrawerMenu(
        savedRegions: savedRegions,
        onRegionAdded: onRegionAdded,
        onRegionSelected: onRegionSelected,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📍 선택 지역: $selectedRegion", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                pm10 == '' ? '' : '미세먼지 등급: $dustGrade',
                style: TextStyle(color: dustColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                pm10 == '' ? '' : getDustComment(pm10),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),

              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  temperature == '' ? '--°' : '$temperature°',
                  style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: hourlyForecasts.take(6).map((forecast) {
                    final hour = forecast.time.substring(0, 2);
                    final icon = getWeatherIcon(forecast.sky, forecast.pty);
                    return Column(
                      children: [
                        Text('$hour시', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        Icon(icon, color: Colors.white),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoRow(Icons.water_drop, '습도', humidity, ' %'),
                        buildInfoRow(Icons.umbrella, '강수 형태', ptyState),
                        buildInfoRow(Icons.air, '미세먼지', pm10, ' ㎍/㎥'),
                        buildInfoRow(Icons.air_outlined, '초미세먼지', pm25, ' ㎍/㎥'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
