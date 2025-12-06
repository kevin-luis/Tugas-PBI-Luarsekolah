// lib/features/home/presentation/widgets/banner_carousel_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class BannerCarouselWidget extends GetView<HomeController> {
  const BannerCarouselWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingBanners.value) {
        return const SizedBox(
          height: 160,
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF26A69A),
            ),
          ),
        );
      }

      if (controller.banners.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: controller.bannerController,
              onPageChanged: controller.onBannerPageChanged,
              itemCount: controller.banners.length,
              itemBuilder: (context, index) {
                final banner = controller.banners[index];
                return _buildBannerItem(banner.imageUrl);
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildPageIndicator(),
        ],
      );
    });
  }

  Widget _buildBannerItem(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFF26A69A),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.grey, size: 40),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.banners.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: controller.currentBannerIndex.value == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: controller.currentBannerIndex.value == index
                  ? const Color(0xFF26A69A)
                  : Colors.grey[300],
            ),
          ),
        ),
      );
    });
  }
}