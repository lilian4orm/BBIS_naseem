import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../provider/student/student_provider.dart';
import '../../../static_files/my_color.dart';
import '../pages/show_latest_news.dart';

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LatestNewsProvider>(
      builder: (provider) {
        if (provider.newsData.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(),
              const SizedBox(height: 16),
              _buildNewsCarousel(provider.newsData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: MyColor.purple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'latestNews'.tr,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: MyColor.black,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCarousel(List<dynamic> newsData) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: newsData.length,
        itemBuilder: (context, index) {
          return _NewsCard(newsData: newsData[index]);
        },
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final Map newsData;

  const _NewsCard({required this.newsData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Get.to(() => ShowLatestNews(data: newsData)),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MyColor.purple.withOpacity(0.7),
                  MyColor.purple.withOpacity(0.9),
                ],
              ),
            ),
            child: Stack(
              children: [
                _buildBackgroundImage(),
                _buildNewsTitle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          "assets/img/t1.png",
          fit: BoxFit.cover,
          opacity: const AlwaysStoppedAnimation(0.3),
        ),
      ),
    );
  }

  Widget _buildNewsTitle() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Text(
          newsData['latest_news_title']?.toString() ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
