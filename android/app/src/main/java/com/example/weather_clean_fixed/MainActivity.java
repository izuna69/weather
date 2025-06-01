package com.example.weather_clean_fixed;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.app_weather_project/widget";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("refresh")) {
                        Context context = getApplicationContext();

                        // ✅ 위젯 업데이트 브로드캐스트 전송
                        Intent intent = new Intent(context, WeatherWidget.class);
                        intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);

                        int[] ids = AppWidgetManager.getInstance(context)
                                .getAppWidgetIds(new ComponentName(context, WeatherWidget.class));
                        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);

                        context.sendBroadcast(intent);
                        result.success("updated");
                    } else {
                        result.notImplemented();
                    }
                });
    }
}
