import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MapStudentProvider extends GetxController{
  Map newsData = {};
  bool isLocationServiceEnabled = false;
  bool permission =false;
  void addData(Map newsData) {
    this.newsData = newsData;
    update();
  }
  void serviceLocation(bool isLocationServiceEnabled){
    this.isLocationServiceEnabled = isLocationServiceEnabled;
    update();
  }
  void permissionLocation(bool isPermissionEnabled){
    permission = isPermissionEnabled;
    update();
  }
}
class SocketDataProvider extends GetxController{
  late  IO.Socket socket;
  bool isLocationServiceEnabled = false;
  bool permission =false;
  void changeSocket(IO.Socket socket) {
    this.socket = socket;
    update();
  }
}

