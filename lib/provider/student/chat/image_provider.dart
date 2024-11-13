import 'dart:io';

import 'package:get/get.dart';

class ImageGroupProvider extends GetxController {
  File? pic;
  changeImage(File picR) {
    pic = picR;
    update();
  }
}
