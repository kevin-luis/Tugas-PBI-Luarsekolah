// lib/features/home/presentation/widgets/program_menu_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class ProgramMenuWidget extends GetView<HomeController> {
  const ProgramMenuWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Program dari Luarsekolah',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingPrograms.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF26A69A),
                ),
              );
            }

            if (controller.programs.isEmpty) {
              return const Center(
                child: Text('Tidak ada program tersedia'),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: controller.programs
                  .map((program) => _buildMenuItem(program))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(program) {
    return GestureDetector(
      onTap: () => controller.onProgramMenuTap(program),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 56,
            decoration: BoxDecoration(
              color: program.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(program.icon, color: program.color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            program.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}