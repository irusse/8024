import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/components/shaped_cached_image.dart';

class ProfileAvatarPicker extends StatelessWidget {
  final XFile? selectedImageFile;
  final String? currentAvatarUrl;
  final VoidCallback onImagePick;
  final VoidCallback? onImageClear;
  final double radius;

  const ProfileAvatarPicker({
    super.key,
    required this.selectedImageFile,
    required this.currentAvatarUrl,
    required this.onImagePick,
    this.onImageClear,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onImagePick,
      child: Stack(
        children: [
          _buildAvatarImage(),
          _buildCameraIcon(context),
          if (selectedImageFile != null && onImageClear != null)
            _buildClearButton(context),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (selectedImageFile != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(selectedImageFile!.path)),
      );
    } else {
      return ShapedCachedImage(
        url: currentAvatarUrl,
        radius: radius,
      );
    }
  }

  Widget _buildCameraIcon(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: context.color.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.camera_alt,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: onImageClear,
        child: Container(
          decoration: BoxDecoration(
            color: context.color.tertiary,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.close,
            size: 16,
            color: context.color.basicRed,
          ),
        ),
      ),
    );
  }
}