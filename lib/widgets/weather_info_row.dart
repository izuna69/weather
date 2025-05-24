import 'package:flutter/material.dart';

class WeatherInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const WeatherInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
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
}
