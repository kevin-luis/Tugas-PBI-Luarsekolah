// lib/features/home/data/datasources/home_remote_data_source.dart

import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../models/program_menu_model.dart';
import '../models/class_model.dart';
import '../models/subscription_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<BannerModel>> getBanners();
  Future<List<ProgramMenuModel>> getPrograms();
  Future<List<ClassModel>> getPopularClasses();
  Future<List<SubscriptionModel>> getSubscriptions();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<List<BannerModel>> getBanners() async {
    // Simulasi API call - ganti dengan actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      BannerModel(
        id: '1',
        imageUrl: 'https://www.luarsekolah.com/_next/image?url=https%3A%2F%2Ffile.luarsekolah.com%2Fstorage%2Flive%2Fslider%2F77-68f5e55990cc2.jpeg&w=1920&q=75',
        title: 'Banner 1',
      ),
      BannerModel(
        id: '2',
        imageUrl: 'https://www.luarsekolah.com/_next/image?url=https%3A%2F%2Ffile.luarsekolah.com%2Fstorage%2Flive%2Fslider%2F78-68f5e5b59002b.png&w=1920&q=75',
        title: 'Banner 2',
      ),
      BannerModel(
        id: '3',
        imageUrl: 'https://www.luarsekolah.com/_next/image?url=https%3A%2F%2Ffile.luarsekolah.com%2Fstorage%2Flive%2Fslider%2F79-691e979e716bf.png&w=1920&q=75',
        title: 'Banner 3',
      ),
    ];
  }

  @override
  Future<List<ProgramMenuModel>> getPrograms() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      ProgramMenuModel(
        id: '1',
        label: 'Prakerja',
        icon: Icons.work_outline,
        color: const Color(0xFF42A5F5),
      ),
      ProgramMenuModel(
        id: '2',
        label: 'magang+',
        icon: Icons.add_circle_outline,
        color: const Color(0xFFFF9800),
      ),
      ProgramMenuModel(
        id: '3',
        label: 'Subs',
        icon: Icons.school_outlined,
        color: const Color(0xFFEF5350),
      ),
      ProgramMenuModel(
        id: '4',
        label: 'Lainnya',
        icon: Icons.apps,
        color: const Color(0xFF9E9E9E),
      ),
    ];
  }

  @override
  Future<List<ClassModel>> getPopularClasses() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return [
      ClassModel(
        id: '1',
        title: 'Teknik Pemilahan dan Pengolahan Sampah',
        price: 'Rp 1.500.000',
        rating: 4.5,
        color: Colors.green[700]!,
        icon: Icons.recycling,
        category: 'Prakerja',
        totalStudents: 1250,
      ),
      ClassModel(
        id: '2',
        title: 'Meningkatkan Pertumbuhan Penjualan',
        price: 'Rp 1.500.000',
        rating: 4.5,
        color: Colors.lightGreen[600]!,
        icon: Icons.trending_up,
        category: 'Prakerja',
        totalStudents: 980,
      ),
    ];
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return [
      SubscriptionModel(
        id: '1',
        title: '5 Kelas Pembelajaran',
        subtitle: 'Belajar SwiftUI Untuk Pembuatan Interface',
        color: const Color(0xFF8B5CF6),
        gradientColors: [
          const Color(0xFF8B5CF6),
          const Color(0xFF7C3AED),
        ],
        icon: Icons.apple,
        backgroundColor: Colors.purple[50]!,
        totalClasses: 5,
      ),
      SubscriptionModel(
        id: '2',
        title: '5 Kelas',
        subtitle: 'Belajar Dart Untuk Pembuatan Aplikasi',
        color: const Color(0xFF06B6D4),
        gradientColors: [
          const Color(0xFF06B6D4),
          const Color(0xFF0891B2),
        ],
        icon: Icons.code,
        backgroundColor: Colors.cyan[50]!,
        totalClasses: 5,
      ),
    ];
  }
}