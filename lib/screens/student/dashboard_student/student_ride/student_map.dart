import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:BBInaseem/static_files/my_color.dart';
import '../../../../provider/student/provider_maps.dart';
import '../../../../static_files/my_loading.dart';
import 'driver_map_socket.dart';

class StudentsMap extends StatefulWidget {
  const StudentsMap({Key? key}) : super(key: key);

  @override
  _StudentsMapState createState() => _StudentsMapState();
}

class _StudentsMapState extends State<StudentsMap> {
  final MapStudentProvider mapStudentProvider = Get.put(MapStudentProvider());
  GoogleMapController? _controller;
  StreamSubscription? _locationSubscription;
  _animateCamera(lit, lng) {
    if (_controller != null) {
      _controller!.getZoomLevel().then((value) {
        _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(bearing: 180, target: LatLng(lit, lng), tilt: 40, zoom: value)));
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


  @override
  void initState() {
    ConnectSocket().initSocket();
    super.initState();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  updateMarker(lit, lng) async {
    //final Uint8List markerIcon = await getBytesFromAsset('assets/img/logo.jpg', 100);
    //BitmapDescriptor.fromBytes(markerIcon)
    Marker _marker = Marker(
      markerId: MarkerId(DateTime.now().millisecondsSinceEpoch.toString()),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(lit, lng),
    );
    _animateCamera(lit, lng);
    markers.clear();
    markers.add(_marker);
  }
  var _mapType = MapType.normal;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.yellow,
        foregroundColor: MyColor.purple,
        title: const Text("الخارطة"),
        centerTitle: true,
      ),
      body: GetBuilder<MapStudentProvider>(
        builder: (_data) {
          Logger().i(_data.newsData);
          // if(_data.permission && _data.isLocationServiceEnabled){
          //
          // }
          return _data.newsData.isNotEmpty ? _gMap(_data.newsData['latitude'], _data.newsData['longitude']) : Center(child: busSchoolMoving());
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _goToTheLake, child: const Icon(Icons.map_outlined),backgroundColor: MyColor.yellow,),
    );
  }

  _goToTheLake() {
    _mapType == MapType.normal ? _mapType = MapType.hybrid : _mapType = MapType.normal;
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

}
