String getPersonalizedComment({
  required String pm10Value,
  required String ptyCode,
  required String skyCode,
}) {
  final int pm10 = int.tryParse(pm10Value) ?? 0;
  final bool isRain = ptyCode != '0';
  final bool isCloudy = skyCode == '3' || skyCode == '4';

  if (pm10 <= 30) {
    if (isRain) return '미세먼지는 좋지만 비가 오니 우산을 챙기세요!';
    if (isCloudy) return '미세먼지는 좋고 흐린 날이니 산책하기 딱 좋아요!';
    return '맑고 공기질도 좋아요. 야외활동 추천!';
  }

  if (pm10 <= 80) {
    if (isRain) return '공기는 보통인데 비가 오네요. 외출 시 우산 필수!';
    if (isCloudy) return '공기는 보통, 흐린 날씨에 기분 전환 산책도 괜찮아요.';
    return '공기는 보통이에요. 날씨 좋으면 가볍게 나가보세요.';
  }

  if (isRain) return '미세먼지도 안 좋고 비까지 옵니다. 외출은 최소화하세요.';
  if (isCloudy) return '미세먼지가 나쁘고 흐려요. 가급적 실내에 계세요.';
  if (pm10 > 80) return '미세먼지가 매우 안좋아요. 외출은 자제하고 꼭 마스크 착용하세요.';

  // ✅ 안전장치로 마지막 return 추가 (실제로 여기까지 오진 않더라도 Dart가 요구함)
  return '날씨 정보가 부족하여 안내 문구를 제공할 수 없습니다.';
}
