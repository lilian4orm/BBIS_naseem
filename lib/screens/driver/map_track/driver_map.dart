import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../../provider/driver/provider_maps.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import 'driver_map_socket.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DriversMap extends StatefulWidget {
  final IO.Socket socket;
  const DriversMap({super.key, required this.socket});

  @override
  _DriversMapState createState() => _DriversMapState();
}

class _DriversMapState extends State<DriversMap> {
  final MapDataProvider _mapDataProvider = Get.put(MapDataProvider());
  GoogleMapController? _controller;
  StreamSubscription? _locationSubscription;
  _animateCamera(lit, lng) {
    if (_controller != null) {
      _controller!.getZoomLevel().then((value) {
        _controller!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                bearing: 180,
                target: LatLng(lit, lng),
                tilt: 40,
                zoom: value)));
      });
    }
  }
  // void getCurrentLocation(lit, lng) async {
  //   try {
  //     if (_locationSubscription != null) {
  //       _locationSubscription!.cancel();
  //     }
  //     if (_controller != null) {
  //       _controller!.getZoomLevel().then((value) {
  //         _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(bearing: 180, target: LatLng(lit, lng), tilt: 40, zoom: value)));
  //       });
  //     }
  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       debugPrint("Permission Denied");
  //     }
  //   }
  // }

  Set<Marker> markers = {};
  //Set<Marker> markers = Set.from([]);

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    super.dispose();
  }

  runSocket() {
    if (_mapDataProvider.permission &&
        _mapDataProvider.isLocationServiceEnabled) {
      ConnectSocket().initSocket(widget.socket);
    }
  }

  @override
  void initState() {
    checkIsLocationServiceEnabled();
    super.initState();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  updateMarker(lit, lng) async {
    //final Uint8List markerIcon = await getBytesFromAsset('assets/img/logo.jpg', 100);
    //BitmapDescriptor.fromBytes(markerIcon)
    Marker marker = Marker(
      markerId: MarkerId(DateTime.now().millisecondsSinceEpoch.toString()),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(lit, lng),
    );
    _animateCamera(lit, lng);
    markers.clear();
    markers.add(marker);
  }

  checkIsLocationServiceEnabled() async {
    ///service Enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _mapDataProvider.serviceLocation(serviceEnabled);

    ///Location Permission
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always) {
      _mapDataProvider.permissionLocation(true);
      runSocket();
    }
    if (permission == LocationPermission.whileInUse) {
      _mapDataProvider.permissionLocation(true);
      runSocket();
    }
  }

  var _mapType = MapType.normal;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.yellow,
        foregroundColor: MyColor.purple,
        title: Text("map".tr),
        centerTitle: true,
      ),
      body: GetBuilder<MapDataProvider>(
        builder: (data) {
          if (!data.isLocationServiceEnabled) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  locationEnable(),
                  Text(
                    'plzgps'.tr,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MyColor.purple),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    onPressed: _requestEnableLocation,
                    color: MyColor.purple,
                    textColor: MyColor.yellow,
                    child: Text('actGps'.tr),
                  )
                ],
              ),
            );
          }
          if (!data.permission) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  locationEnable(),
                  Text(
                    'plzgps'.tr,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MyColor.purple),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    onPressed: _requestPermissionLocation,
                    color: MyColor.yellow,
                    textColor: MyColor.purple,
                    child: Text('aloGps'.tr),
                  )
                ],
              ),
            );
          }
          // if(_data.permission && _data.isLocationServiceEnabled){
          //
          // }
          return data.newsData.isNotEmpty
              ? _gMap(data.newsData['latitude'], data.newsData['longitude'])
              : Center(child: busSchoolMoving());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToTheLake,
        backgroundColor: MyColor.yellow,
        child: const Icon(Icons.map_outlined),
      ),
    );
  }

  _goToTheLake() {
    _mapType == MapType.normal
        ? _mapType = MapType.hybrid
        : _mapType = MapType.normal;
  }

  _gMap(latitude, longitude) {
    updateMarker(latitude, longitude);
    return GoogleMap(
      mapType: _mapType,
      trafficEnabled: true,
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 16,
      ),
      markers: markers,
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
    );
  }

  _requestEnableLocation() async {
    Location location = Location();
    bool serviceEnabled;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      } else {
        _mapDataProvider.serviceLocation(serviceEnabled);
        runSocket();
      }
    } else {
      _mapDataProvider.serviceLocation(serviceEnabled);
      runSocket();
    }
  }

  _requestPermissionLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    if (permission == LocationPermission.always) {
      _mapDataProvider.permissionLocation(true);
      runSocket();
    }
    if (permission == LocationPermission.whileInUse) {
      _mapDataProvider.permissionLocation(true);
      runSocket();
    }
  }
}
