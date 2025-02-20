package com.example.internet_connection_status

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    
    val api: InternetConnectionApi = InternetConnectionApiImpl(applicationContext)
    InternetConnectionApi.setUp(flutterEngine.dartExecutor.binaryMessenger, api)
  }
}