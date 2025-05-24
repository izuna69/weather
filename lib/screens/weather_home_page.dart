import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/weather_service.dart';
import '../services/dust_service.dart';
import '../services/convert_to_grid.dart';
import '../services/weather_comment_service.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/hourly_forecast_bar.dart';
import '../widgets/weather_info_row.dart';
import '../models/hourly_forecast.dart';
import '../utils/region_grid_map.dart';

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
  String selectedRegion = '내 위치';

  List<String> savedRegions = [];
  List<String> recentRegions = [];
  Set<String> pinnedRegions = {};
  List<HourlyForecast> hourlyForecasts = [];

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    fetchAllData();

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
    _controller.dispose();
    super.dispose();
  }

  void fetchAllData() async {
    setState(() {
      temperature = '';
      humidity = '';
      pm10 = '';
      pm25 = '';
      skyState = '';
      ptyState = '';
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
        if (coords == null) return;
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
        skyState = weather['sky'] ?? '';
        ptyState = weather['pty'] ?? '';
        pm10 = dust['pm10']!;
        pm25 = dust['pm25']!;
        hourlyForecasts = hourly;
        _controller.forward(from: 0);
      });
    } catch (_) {}
  }

  void onRegionAdded(String region) {
    if (!regionGridMap.containsKey(region)) return;
    if (!savedRegions.contains(region)) {
      setState(() {
        savedRegions.add(region);
      });
    }
  }

  void onRegionRemoved(String region) {
    setState(() {
      savedRegions.remove(region);
      pinnedRegions.remove(region);
    });
  }

  void onRegionSelected(String region) {
    if (regionGridMap.containsKey(region)) {
      setState(() {
        selectedRegion = region;
        recentRegions.remove(region);
        recentRegions.insert(0, region);
        if (recentRegions.length > 5) {
          recentRegions = recentRegions.sublist(0, 5);
        }
      });
      fetchAllData();
    }
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
      case '좋음': return Colors.green;
      case '보통': return Colors.yellow;
      case '나쁨': return Colors.orange;
      case '매우나쁨': return Colors.red;
      default: return Colors.white;
    }
  }

  IconData getWeatherIcon(String sky, String pty) {
    if (pty == '1') return Icons.water_drop;
    if (pty == '2' || pty == '3') return Icons.ac_unit;
    if (pty == '4') return Icons.grain;

    switch (sky) {
      case '1': return Icons.wb_sunny;
      case '3': return Icons.cloud_queue;
      case '4': return Icons.cloud;
      default: return Icons.help_outline;
    }
  }

  Widget getDustCommentWidget() {
    return Text(
      pm10 == '' ? '' : getPersonalizedComment(
        pm10Value: pm10,
        ptyCode: ptyState,
        skyCode: skyState,
      ),
      style: const TextStyle(color: Colors.white, fontSize: 14),
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
        recentRegions: recentRegions,
        pinnedRegions: pinnedRegions,
        onRegionAdded: onRegionAdded,
        onRegionSelected: onRegionSelected,
        onRegionRemoved: onRegionRemoved,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("\uD83D\uDCCD 선택 지역: $selectedRegion", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                pm10 == '' ? '' : '미세먼지 등급: $dustGrade',
                style: TextStyle(color: dustColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              getDustCommentWidget(),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  temperature == '' ? '--\u00B0' : '$temperature\u00B0',
                  style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              HourlyForecastBar(
                forecasts: hourlyForecasts,
                getWeatherIcon: getWeatherIcon,
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
                        WeatherInfoRow(icon: Icons.water_drop, label: '습도', value: humidity, unit: ' %'),
                        WeatherInfoRow(icon: Icons.umbrella, label: '강수 형태', value: ptyState),
                        WeatherInfoRow(icon: Icons.air, label: '미세먼지', value: pm10, unit: ' ㎍/㎥'),
                        WeatherInfoRow(icon: Icons.air_outlined, label: '초미세먼지', value: pm25, unit: ' ㎍/㎥'),
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