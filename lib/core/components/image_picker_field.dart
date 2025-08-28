import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

class ImagePickerField extends StatelessWidget {
  final XFile? pickedImage;
  final String? photoUrl;
  final Future<void> Function() onPickImage;
  final VoidCallback onRemoveImage;
  final bool isCircular;
  final double width;
  final double height;
  final double borderRadius;

  const ImagePickerField({
    super.key,
    required this.pickedImage,
    this.photoUrl,
    required this.onPickImage,
    required this.onRemoveImage,
    this.width = 90,
    this.height = 90,
    this.borderRadius = 8,
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        pickedImage != null || (photoUrl != null && photoUrl!.isNotEmpty);

    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: UIConstants.getDefaultBorder(context, false),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: !hasImage
            ? CustomOutlinedButton(
                onPressed: onPickImage,
                text: 'Загрузить фото',
              )
            : Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: width,
                    height: isCircular ? width : height,
                    decoration: BoxDecoration(
                      shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                      border: isCircular
                          ? Border.all(
                              color: context.color.primaryText,
                              width: 4,
                            )
                          : null,
                      borderRadius: isCircular
                          ? null
                          : BorderRadius.circular(borderRadius),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildImage(),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onRemoveImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.color.basicRed,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImage() {
    if (pickedImage != null) {
      return isCircular
          ? CircleAvatar(
              radius: width / 2,
              backgroundImage: FileImage(File(pickedImage!.path)),
            )
          : Image.file(
              File(pickedImage!.path),
              fit: BoxFit.cover,
            );
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      return isCircular
          ? CircleAvatar(
              radius: width / 2,
              backgroundImage: NetworkImage(photoUrl!),
            )
          : Image.network(
              photoUrl!,
              fit: BoxFit.cover,
            );
    } else {
      return const SizedBox.shrink();
    }
  }
}
