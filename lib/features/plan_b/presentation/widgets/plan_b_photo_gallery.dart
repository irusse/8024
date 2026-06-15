import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_photo_entity.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PlanBPhotoGallery extends StatefulWidget {
  final List<PlanBPhotoEntity> photos;

  const PlanBPhotoGallery({super.key, required this.photos});

  @override
  State<PlanBPhotoGallery> createState() => _PlanBPhotoGalleryState();
}

class _PlanBPhotoGalleryState extends State<PlanBPhotoGallery> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 280,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            enableInfiniteScroll: widget.photos.length > 1,
            autoPlay: widget.photos.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) {
              setState(() {
                _currentPhotoIndex = index;
              });
            },
          ),
          items: widget.photos.asMap().entries.map((entry) {
            final index = entry.key;
            final photo = entry.value;
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => _openPhotoViewer(context, index),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: context.color.tertiary.withValues(alpha: .2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: photo.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: context.color.tertiary.withValues(alpha: .1),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: context.color.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: context.color.tertiary.withValues(alpha: .1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: context.color.secondaryText,
                              ),
                              const VerticalGap(8),
                              Text(
                                'Не удалось загрузить фото',
                                style: context.text.bodySmall.copyWith(
                                  color: context.color.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        if (widget.photos.length > 1) ...[
          const VerticalGap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.photos.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPhotoIndex == entry.key
                      ? context.color.primary
                      : context.color.tertiary.withValues(alpha: .3),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _openPhotoViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PhotoViewerScreen(
          photos: widget.photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _PhotoViewerScreen extends StatefulWidget {
  final List<PlanBPhotoEntity> photos;
  final int initialIndex;

  const _PhotoViewerScreen({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: DefaultAppBar(
        title: "${_currentIndex + 1} / ${widget.photos.length}",
        showBackButton: true,
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.photos.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(
              widget.photos[index].url,
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            heroAttributes: PhotoViewHeroAttributes(
              tag: widget.photos[index].id,
            ),
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
              );
            },
          );
        },
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: context.color.background,
        ),
        loadingBuilder: (context, event) {
          return Center(
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded /
                      (event.expectedTotalBytes ?? 1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
      ),
    );
  }
}
