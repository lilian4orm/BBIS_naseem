import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../../../api_connection/auth_connection.dart';
import '../../../api_connection/student/api_profile.dart';
import '../../../provider/auth_provider.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_random.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? imageUrl;
  final String contentUrl;
  final VoidCallback? onImageUpdated;

  const ProfileImagePicker({
    super.key,
    this.imageUrl,
    required this.contentUrl,
    this.onImageUpdated,
  });

  Future<void> _pickAndUploadImage() async {
    EasyLoading.show(status: "loading".tr);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        XFile file = XFile(result.files.single.path!);
        final compressedFile = await _compressImage(file, p.dirname(file.path));

        if (compressedFile != null) {
          await _uploadImage(compressedFile);
        }
      }
    } catch (e) {
      EasyLoading.showError('errorFound'.tr);
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<XFile?> _compressImage(XFile file, String targetPath) async {
    String randomName = RandomGen().getRandomString(5);
    return await FlutterImageCompress.compressAndGetFile(
      file.path,
      "$targetPath/img_$randomName.jpg",
      quality: 40,
    );
  }

  Future<void> _uploadImage(XFile file) async {
    final dataProvider = Get.put(MainDataGetProvider()).mainData;

    dio.FormData formData = dio.FormData.fromMap({
      "account_img": dio.MultipartFile.fromFileSync(
        file.path,
        filename: 'pic.jpg',
        contentType: MediaType('image', 'jpg'),
      ),
      "account_img_old": dataProvider['account']?['account_img'],
    });

    final response = await StudentProfileAPI().editImgProfile(formData);

    if (response['error'] == false) {
      await Auth().getStudentInfo();
      EasyLoading.showSuccess('changeImgSuccess'.tr);
      onImageUpdated?.call();
    } else {
      EasyLoading.showError('errorFound'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildProfileImage(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildEditBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: Colors.white,
        child: Image.asset(
          "assets/img/graduated.png",
          fit: BoxFit.cover,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: contentUrl + imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(color: MyColor.purple),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.white,
        child: Image.asset(
          "assets/img/graduated.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEditBadge() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.camera_alt,
        size: 16,
        color: MyColor.purple,
      ),
    );
  }
}
