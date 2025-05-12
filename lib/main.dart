import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'weather_service.dart';
import 'convert_to_grid.dart';
import 'dust_service.dart';
import 'drawer_menu.dart'; // ✅ 새로 만든 Drawer 파일

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

      setState(() {
        temperature = weather['temperature']!;
        humidity = weather['humidity']!;
        skyState = getSkyText(weather['sky'] ?? '');
        ptyState = getPtyText(weather['pty'] ?? '');
        pm10 = dust['pm10']!;
        pm25 = dust['pm25']!;
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
      drawer: DrawerMenu(
        savedRegions: savedRegions,
        onRegionAdded: onRegionAdded,
        onRegionSelected: onRegionSelected,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🕒 현재 시간: $currentTime', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
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
            if (errorVisible)
              Text('❌ 오류: $errorMessage', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            if (weatherVisible)
              SlideTransition(
                position: _slideAnimation,
                child: Column(
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
              ),
          ],
        ),
      ),
    );
  }
}
