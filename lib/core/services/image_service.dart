import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:neighbours/core/constants/default_constants.dart';

abstract class ImageService {
  Future<XFile?> pickImage(ImageSource source,
      {int imageQuality = DefaultConstants.imageQuality,
      double maxWidth = 512,
      double maxHeight = 512});
}

@Singleton(as: ImageService)
class ImageServiceImpl implements ImageService {
  final _picker = ImagePicker();

  @override
  Future<XFile?> pickImage(ImageSource source,
      {int imageQuality = DefaultConstants.imageQuality,
      double maxWidth = 512,
      double maxHeight = 512}) {
    return _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxHeight: maxWidth,
        maxWidth: maxHeight);
  }
}
