import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/internet_connection_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/com/example/internet_connection_status/InternetConnectionApi.g.kt',
    kotlinOptions: KotlinOptions(),
    swiftOut: 'ios/Runner/InternetConnectionApi.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
@HostApi()
abstract class InternetConnectionApi {
  bool hasInternetConnection();
}
