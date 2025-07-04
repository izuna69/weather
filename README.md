# Weather 앱 소개

시작일: 05/11/2025
종료일: 06/23/2025 
담당자: 김진영  



### 디자인 툴 - [피그마](https://www.figma.com/design/ttHZrIvWEsbmKpuHlHbROI/Weather?node-id=8-33&t=z0YeE2T4QWUhpgm8-1)  

### 프로젝트 계획서 - [노션](https://www.notion.so/1fa4f7ca3dd9814ca017db686fb3501c?pvs=4)  평가해주실 파일입니다.  

### 프로젝트 진행도 - [간트차트](https://www.notion.so/1fa4f7ca3dd9806ea3a8f954c73a61cb?v=1fa4f7ca3dd981429a1c000c4c265773&pvs=4) 

---

### 🚀 릴리스 정보

[+모든 릴리스](https://github.com/izuna69/weather/releases/tag/Main)

| 버전   | 일자        | 주요 변경 사항                                                                 | 다운로드 |
|--------|-------------|----------------------------------------------------------------------------------|-----------|
| 0.2.1  | 2025-06-02  | **홈 화면 위젯 기능 추가**<br>날씨 정보가 바탕화면 위젯에 표시됨                            | [📦 APK 다운로드](https://github.com/izuna69/weather/releases/download/v0.2.1/app-release_0.2.1.apk) |
| 0.2.0  | 2025-06-01  | **로컬 영속 저장 기능** 추가<br>즐겨찾기 지역이 앱을 껐다 켜도 유지됨                   | [📦 APK 다운로드](https://github.com/izuna69/weather/releases/download/0.2.0/app-release_0.2.0.apk) |
| 0.1.1  | 2025-05-25  | 위치 기반 날씨, 미세먼지 정보, 시간별 예보, 주간 예보, 지역 즐겨찾기 기능 포함             | [📦 APK 다운로드](https://github.com/izuna69/weather/releases/download/Main/app-release_0.1.1.zip) |



### 🧾 프로젝트 소개

이 앱은 Flutter를 기반으로 제작된 **모바일 날씨 애플리케이션**으로, 사용자의 현재 위치 또는 선택한 지역에 대해 다음과 같은 **실시간 기상 정보를 제공합니다.**

- 현재 온도, 습도, 강수 형태 등 실시간 날씨
- 시간대별 기상 예보 (아이콘 포함)
- 미세먼지(PM10) 및 초미세먼지(PM2.5) 수치
- 지역 즐겨찾기 및 저장 기능
- 영속성 로컬스토리지 기능추가 


### 🎯 개발 목적

> 기상청 공공 API를 활용하여 날씨 데이터를 얼마나 신속하고 정확하게 가져올 수 있는지를 연구하고, 사용자 친화적인 날씨 UI를 Flutter 프레임워크로 구현하는 것이 목표입니다.
> 

### 🛠️ 주요 기능

| 기능 | 설명 |
| --- | --- |
| 📍 현재 위치 기반 날씨 조회 | 위치 권한을 이용해 실시간 날씨 데이터 표시 |
| 📁 지역 즐겨찾기 | 자주 조회할 지역을 드로어 메뉴에 저장 가능 |
| 🌦 시간대별 예보 | 향후 몇 시간간의 날씨 예보를 아이콘과 함께 시각적으로 제공 |
| 🌀 대기질 정보 | PM10/PM2.5 수치를 기반으로 대기 상태 등급 및 코멘트 제공 |
| 🎨 부드러운 애니메이션 UI | 날씨 정보가 슬라이드 애니메이션으로 나타나도록 구현 |

### 🧱 사용 기술 스택

- **Flutter** (Dart)
- **Geolocator**, **permission_handler** (위치 권한 처리)
- **http** (API 통신)
- **Python**
- **Node.js**

### 🌐 API

- [기상청 초단기예보 공공데이터](https://www.data.go.kr/iim/api/selectAPIAcountView.do) 
- Hugging Face Space 요약 
- Flask KoBART
- 환경부 대기질 



### 📅 개발 기간

- 시작일: 2025년 5월 11일
- 중단일: 2025년 6월 23일
- 상태: 개발 중단
- 사유: 목표기능 완성
