import 'dart:math';

Map<String, int> convertToGrid(double lat, double lon) {
  const double RE = 6371.00877;
  const double GRID = 5.0;
  const double SLAT1 = 30.0;
  const double SLAT2 = 60.0;
  const double OLON = 126.0;
  const double OLAT = 38.0;
  const double XO = 43;
  const double YO = 136;

  const double DEGRAD = pi / 180.0;

  double re = RE / GRID;
  double slat1 = SLAT1 * DEGRAD;
  double slat2 = SLAT2 * DEGRAD;
  double olon = OLON * DEGRAD;
  double olat = OLAT * DEGRAD;

  double sn = tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5);
  sn = log(cos(slat1) / cos(slat2)) / log(sn);
  double sf = tan(pi * 0.25 + slat1 * 0.5);
  sf = pow(sf, sn) * cos(slat1) / sn;
  double ro = tan(pi * 0.25 + olat * 0.5);
  ro = re * sf / pow(ro, sn);

  double ra = tan(pi * 0.25 + lat * DEGRAD * 0.5);
  ra = re * sf / pow(ra, sn);
  double theta = lon * DEGRAD - olon;
  if (theta > pi) theta -= 2.0 * pi;
  if (theta < -pi) theta += 2.0 * pi;
  theta *= sn;

  int x = (ra * sin(theta) + XO + 0.5).floor();
  int y = (ro - ra * cos(theta) + YO + 0.5).floor();

  return {'nx': x, 'ny': y};
}
