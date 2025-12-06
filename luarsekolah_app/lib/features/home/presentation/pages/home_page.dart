// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/banner_carousel_widget.dart';
import '../widgets/program_menu_widget.dart';
import '../widgets/voucher_section_widget.dart';
import '../widgets/popular_classes_widget.dart';
import '../widgets/subscriptions_widget.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

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
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const BannerCarouselWidget(),
                    const SizedBox(height: 24),
                    const ProgramMenuWidget(),
                    const SizedBox(height: 16),
                    const VoucherSectionWidget(),
                    const SizedBox(height: 24),
                    const PopularClassesWidget(),
                    const SizedBox(height: 24),
                    const SubscriptionsWidget(),
                    const SizedBox(height: 24),
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
