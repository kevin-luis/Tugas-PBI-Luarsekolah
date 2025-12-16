// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:luarsekolah_app/features/home/presentation/controllers/home_controller.dart';
import 'package:luarsekolah_app/features/home/presentation/widgets/home_header_widget.dart';
import 'package:luarsekolah_app/features/home/presentation/widgets/banner_carousel_widget.dart';
import 'package:luarsekolah_app/features/home/presentation/widgets/program_menu_widget.dart';
import 'package:luarsekolah_app/features/home/presentation/widgets/voucher_section_widget.dart';
import 'package:luarsekolah_app/features/home/presentation/widgets/popular_classes_widget.dart';
import 'package:luarsekolah_app/features/home/presentation/widgets/subscriptions_widget.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF26A69A),
      body: RefreshIndicator(
        onRefresh: controller.refreshPage,
        color: const Color(0xFF26A69A),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Custom refresh control for iOS
            CupertinoSliverRefreshControl(
              onRefresh: controller.refreshPage,
              builder: (context, refreshState, pulledExtent,
                  triggerPullDistance, indicatorExtent) {
                final bool refreshing =
                    refreshState == RefreshIndicatorMode.refresh ||
                        refreshState == RefreshIndicatorMode.done;
                final double opacity =
                    (pulledExtent / triggerPullDistance).clamp(0.0, 1.0);

                return SizedBox(
                  height: pulledExtent,
                  child: Center(
                    child: Opacity(
                      opacity: opacity,
                      child: SizedBox(
                        height: 80,
                        child: Lottie.asset(
                          'assets/lottie/sandy_loading.json',
                          animate: refreshing,
                          repeat: true,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Header with profile
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: false,
              backgroundColor: const Color(0xFF26A69A),
              elevation: 0,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double progress =
                      ((constraints.maxHeight - kToolbarHeight) /
                              (120.0 - kToolbarHeight))
                          .clamp(0.0, 1.0);
                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero,
                    background: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: SafeArea(
                        child: HomeHeaderWidget(progress: progress),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main content
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: const Column(
                  children: [
                    SizedBox(height: 20),
                    BannerCarouselWidget(),
                    SizedBox(height: 24),
                    ProgramMenuWidget(),
                    SizedBox(height: 16),
                    VoucherSectionWidget(),
                    SizedBox(height: 24),
                    PopularClassesWidget(),
                    SizedBox(height: 24),
                    SubscriptionsWidget(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
