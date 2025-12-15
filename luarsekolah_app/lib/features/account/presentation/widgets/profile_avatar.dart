// lib/features/account/presentation/widgets/profile_avatar.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileAvatar extends StatelessWidget {
  final UserProfileEntity? user;
  final String? imagePath;
  final VoidCallback onEditPressed;

  const ProfileAvatar({
    Key? key,
    required this.user,
    this.imagePath,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF26A69A),
            backgroundImage: _getBackgroundImage(),
            child: _getChild(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF26A69A),
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white,
                ),
                onPressed: onEditPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (imagePath != null) {
      return FileImage(File(imagePath!));
    } else if (user?.photoUrl != null) {
      return NetworkImage(user!.photoUrl!);
    }
    return null;
  }

  Widget? _getChild() {
    if (imagePath == null && user?.photoUrl == null) {
      return Text(
        user?.name[0].toUpperCase() ?? 'U',
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }
    return null;
  }
}