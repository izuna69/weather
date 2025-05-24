class HourlyForecast {
  final String time;
  final String sky;
  final String pty;

  HourlyForecast({
    required this.time,
    required this.sky,
    required this.pty,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['fcstTime'] as String,
      sky: json['sky'] as String,
      pty: json['pty'] as String,
    );
  }
}
