import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: IconTestPage()));
}

class IconTestPage extends StatelessWidget {
  const IconTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final testIcons = [
      getWeatherIcon('1', ''),   // 맑음
      getWeatherIcon('3', ''),   // 구름 많음
      getWeatherIcon('4', ''),   // 흐림
      getWeatherIcon('', '1'),   // 비
      getWeatherIcon('', '2'),   // 눈
      getWeatherIcon('', '4'),   // 소나기
      getWeatherIcon('', ''),    // 알 수 없음
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('날씨 아이콘 테스트')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: testIcons.length,
        itemBuilder: (context, index) {
          return Icon(testIcons[index], size: 40);
        },
      ),
    );
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
