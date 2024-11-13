import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../static_files/my_color.dart';
import 'join_kindergarten.dart';
import 'join_school.dart';

class JoinUs extends StatefulWidget {
  const JoinUs({Key? key}) : super(key: key);

  @override
  JoinUsState createState() => JoinUsState();
}

class JoinUsState extends State<JoinUs> {
  final List<String> tabTitles = ['king'.tr, 'school'.tr];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabTitles.length,
      child: Scaffold(
        backgroundColor: MyColor.white0,
        appBar: AppBar(
          backgroundColor: MyColor.yellow,
          title: Text(
            'joinus'.tr,
            style: const TextStyle(color: MyColor.purple),
          ),
          iconTheme: const IconThemeData(
            color: MyColor.purple,
          ),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.black87,
            labelColor: Colors.black87,
            tabs: tabTitles.map((title) => Tab(text: title)).toList(),
          ),
        ),
        body: const TabBarView(
          children: [
            JoinKindergarten(),
            JoinSchool(),
          ],
        ),
      ),
    );
  }
}

Future<String> pickImageSingleGallery() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.image);
  if (result != null) {
    XFile file = XFile(result.files.single.path!);
    String imgCompressed = await compressAndGetFile(file, p.dirname(file.path))
        .then((value) => convertImgToBase64(value!));
    return imgCompressed;
  } else {
    return "";
  }
}

Future<XFile?> compressAndGetFile(XFile file, String targetPath) async {
  String getRand = RandomGen().getRandomString(5);
  var result = await FlutterImageCompress.compressAndGetFile(
      file.path, "$targetPath/img_$getRand.jpg",
      quality: 40);
  return result;
}

String convertImgToBase64(XFile imageBytes) {
  String ext = imageBytes.path.split('.').last;
  final bytes = File(imageBytes.path).readAsBytesSync();
  String base64Image = "data:image/$ext;base64,${base64Encode(bytes)}";
  return base64Image;
}

class RandomGen {
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
