import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weekly_rain_service.dart';

class WeeklyRainWidget extends StatelessWidget {
  final List<DailyRainForecast> forecasts;

  const WeeklyRainWidget({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: forecasts.map((forecast) {
          final weekday = DateFormat.E('ko_KR').format(forecast.date); // 토, 일, 월...
          final dateStr = DateFormat('M/d').format(forecast.date);     // 5/24 이런 형식
          final rainText = forecast.willRain ? '비 옴' : '맑음';
          final rainIcon = forecast.willRain ? Icons.umbrella : Icons.wb_sunny;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(rainIcon, color: Colors.white),
                const SizedBox(width: 10),
                Text('$weekday ($dateStr)', style: const TextStyle(color: Colors.white, fontSize: 16)),
                const Spacer(),
                Text(rainText, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
