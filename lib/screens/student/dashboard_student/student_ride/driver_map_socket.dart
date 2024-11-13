import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../provider/auth_provider.dart';
import '../../../../provider/student/provider_maps.dart';
// import 'package:geoloator_apple/geolocator_apple.dart';
// import 'package:geoloator_android/geolocator_android.dart';
// import 'package:background_location/background_location.dart';

class ConnectSocket {
  final MapStudentProvider mapStudentProvider = Get.put(MapStudentProvider());
  final SocketDataProvider _socketDataProvider = Get.put(SocketDataProvider());
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  initSocket() {
    IO.Socket socket = _socketDataProvider.socket;
    if (!socket.connected) {
      socket.connect();
    } else {
      socket.emit("join_room",
          _mainDataGetProvider.mainData['account']["account_driver"]);
    }
    socket.onConnect((socket) {
      if (socket.connected) {
        socket.emit("join_room",
            _mainDataGetProvider.mainData['account']["account_driver"]);
      }
    });

    socket.on('geo', (data) {
      mapStudentProvider.addData(data);
    });
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // getLocation(_socket) async {
  //   await BackgroundLocation.stopLocationService();
  //   await BackgroundLocation.setAndroidNotification(
  //       title: "تتبع الموقع الحالي");
  //   await BackgroundLocation.startLocationService();
  //   location(_socket);
  // }
}
