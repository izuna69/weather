plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.weather_clean_fixed"
    compileSdk = 35                         // ✅ 33 → 35로 올리기
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.weather_clean_fixed"
        minSdk = 21
        targetSdk = 35                      // ✅ 함께 35로 맞추기
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}


flutter {
    source = "../.."
}
