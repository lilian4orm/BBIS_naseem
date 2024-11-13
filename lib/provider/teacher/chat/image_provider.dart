import 'dart:io';

import 'package:get/get.dart';

class ImageGroupProvider extends GetxController {
  File? pic;
  changeImage(File _pic){
    pic = _pic;
    update();
  }
}
