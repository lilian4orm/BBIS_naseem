import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../provider/auth_provider.dart';
import '../../../static_files/my_color.dart';
import 'profile_image_picker.dart';

class TeacherAppBar extends StatelessWidget {
  final String userName;
  final VoidCallback onVersionTap;
  final VoidCallback onLogoutTap;

  const TeacherAppBar({
    super.key,
    required this.userName,
    required this.onVersionTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: MyColor.purple,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          userName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: _buildAppBarBackground(),
      ),
      actions: [
        _buildActionButton(
          icon: Icons.info_outline,
          tooltip: "version".tr,
          onPressed: onVersionTap,
        ),
        _buildActionButton(
          icon: Icons.logout_rounded,
          tooltip: 'logout'.tr,
          onPressed: onLogoutTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MyColor.purple,
            MyColor.purple.withOpacity(0.85),
            MyColor.purple.withOpacity(0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildDecorativeCircle(
            top: -50,
            right: -50,
            size: 200,
          ),
          _buildDecorativeCircle(
            bottom: -30,
            left: -30,
            size: 150,
          ),
          _buildProfileSection(),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: GetBuilder<MainDataGetProvider>(
        builder: (provider) {
          final imageUrl = provider.mainData['account']?['account_img'];
          return Center(
            child: ProfileImagePicker(
              imageUrl: imageUrl,
              contentUrl: provider.contentUrl,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
