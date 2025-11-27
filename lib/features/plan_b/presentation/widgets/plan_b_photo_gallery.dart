import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_photo_entity.dart';

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
          items: widget.photos.map((photo) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
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
                              style: context.text.bodySmall?.copyWith(
                                color: context.color.secondaryText,
                              ),
                            ),
                          ],
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
}
