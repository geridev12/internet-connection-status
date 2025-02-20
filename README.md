
```

# Internet Connection Status

This project demonstrates how to check the internet connection status using Pigeon without relying on third-party plugins.

## Steps to Achieve Internet Connection Check

### 1. Setup Pigeon

Add Pigeon as a dependency in your `pubspec.yaml` file:

```yaml
dev_dependencies:
  pigeon: ^24.2.1
```

### 2. Define the Pigeon API

Create a new file `pigeons/internet_connection_api.dart` and define the API:

```dart
import 'package:pigeon/pigeon.dart';

class InternetConnectionApi {
  bool hasInternetConnection();
}
```

### 3. Generate the Pigeon Files

Run the following command to generate the Pigeon files:

```sh
flutter pub run pigeon \
  --input pigeons/internet_connection_api.dart \
  --dart_out lib/internet_connection_api.dart \
  --kotlin_out android/app/src/main/kotlin/com/example/internet_connection_status/InternetConnectionApi.g.kt \
  --kotlin_package "com.example.internet_connection_status" \
  --swift_out ios/Runner/InternetConnectionApi.g.swift
```

### 4. Implement the API in Android

Create `InternetConnectionApiImpl.kt` to implement the API:

```kotlin
// filepath: /Users/user/Desktop/internet_connection_status/android/app/src/main/kotlin/com/example/internet_connection_status/InternetConnectionApiImpl.kt
package com.example.internet_connection_status

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities

class InternetConnectionApiImpl(private val context: Context) : InternetConnectionApi {
  override fun hasInternetConnection(): Boolean {
    val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    val network = connectivityManager.activeNetwork ?: return false
    val networkCapabilities = connectivityManager.getNetworkCapabilities(network) ?: return false
    return networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
           networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
  }
}
```

Update `MainActivity.kt` to set up the API:

```kotlin
// filepath: /Users/user/Desktop/internet_connection_status/android/app/src/main/kotlin/com/example/internet_connection_status/MainActivity.kt
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
```

### 5. Implement the API in iOS

Create `InternetConnectionApiImpl.swift` to implement the API:

```swift
// filepath: /Users/user/Desktop/internet_connection_status/ios/Runner/InternetConnectionApiImpl.swift
import Foundation
import SystemConfiguration

class InternetConnectionApiImpl: InternetConnectionApi {
  func hasInternetConnection() throws -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)

    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
        SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
      }
    }

    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
      return false
    }

    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)

    return (isReachable && !needsConnection)
  }
}
```

Update `AppDelegate.swift` to set up the API:

```swift
// filepath: /Users/user/Desktop/internet_connection_status/ios/Runner/AppDelegate.swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let binaryMessenger = controller.binaryMessenger
    let api = InternetConnectionApiImpl()
    InternetConnectionApiSetup.setUp(binaryMessenger: binaryMessenger, api: api)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 6. Add Permissions

Add the `ACCESS_NETWORK_STATE` permission to `AndroidManifest.xml`:

```xml
<!-- filepath: /Users/user/Desktop/internet_connection_status/android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.internet_connection_status">
    <!-- ...existing code... -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <!-- ...existing code... -->
</manifest>
```

### 7. Use the API in Flutter

Create a provider to use the API in Flutter:

```dart
// filepath: /Users/user/Desktop/internet_connection_status/lib/providers/internet_provider.dart
import 'package:flutter/foundation.dart';
import 'package:internet_connection_status/internet_connection_api.dart';

class InternetProvider extends ChangeNotifier {
  bool? hasConnection;

  Future<void> checkInternetConnection() async {
    hasConnection = await InternetConnectionApi().hasInternetConnection();
    notifyListeners();
  }
}
```

Create a home page to display the internet connection status:

```dart
// filepath: /Users/user/Desktop/internet_connection_status/lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:internet_connection_status/providers/internet_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _provider = InternetProvider();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text('Internet Connection'),
    ),
    body: ListenableBuilder(
      listenable: _provider,
      builder:
          (context, child) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                child!,
                const SizedBox(height: 20),
                if (_provider.hasConnection != null) ...[
                  _InternetStatusMessage(isConnected: _provider.hasConnection!),
                ],
              ],
            ),
          ),
      child: ElevatedButton(
        onPressed: () async => _provider.checkInternetConnection(),
        child: const Text('Check Internet Status'),
      ),
    ),
  );
}

class _InternetStatusMessage extends StatelessWidget {
  const _InternetStatusMessage({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) => Text(
    isConnected
        ? 'You are connected to the internet'
        : 'No internet connection. Please check your settings.',
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: isConnected ? Colors.green : Colors.red,
    ),
  );
}
```

Update `main.dart` to use the home page:

```dart
// filepath: /Users/user/Desktop/internet_connection_status/lib/main.dart
import 'package:flutter/material.dart';
import 'package:internet_connection_status/pages/home_page.dart';

void main() => runApp(const MaterialApp(home: HomePage()));
```

### Conclusion

By following these steps, you can check the internet connection status in your Flutter app using Pigeon without relying on third-party plugins.
