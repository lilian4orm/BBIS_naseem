// location_service.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('خدمة الموقع غير مفعّلة');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('تم رفض إذن الموقع');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('تم رفض إذن الموقع بشكل دائم');
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      debugPrint('خطأ في جلب الموقع: $e');
      return null;
    }
  }
}
