import 'package:flutter/material.dart';
import '../models/hourly_forecast.dart'; // 실제 위치에 맞게 수정

class HourlyForecastBar extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final IconData Function(String, String) getWeatherIcon;

  const HourlyForecastBar({
    super.key,
    required this.forecasts,
    required this.getWeatherIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: forecasts.take(6).map((forecast) {
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
    );
  }
}
