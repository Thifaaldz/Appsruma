import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';

class OwnerBrandLogo extends StatelessWidget {
  const OwnerBrandLogo({
    super.key,
    this.height = 24,
    this.alignment = Alignment.centerRight,
  });

  final double height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Image.asset(
        'assets/RUMA LOGO 1.png',
        height: height,
        color: AppTheme.lightBeige,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            'RUMA',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.lightBeige,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          );
        },
      ),
    );
  }
}

class OwnerPanel extends StatelessWidget {
  const OwnerPanel({
    super.key,
    required this.child,
    this.backgroundColor = AppTheme.cardWhite,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class OwnerProfileAvatar extends StatelessWidget {
  const OwnerProfileAvatar({
    super.key,
    required this.imageData,
    this.size = 70,
    this.borderRadius = 18,
    this.shape = BoxShape.rectangle,
  });

  final String imageData;
  final double size;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    Widget child = Icon(
      Icons.person,
      color: AppTheme.lightBeige,
      size: size * 0.54,
    );

    final bytes = _decodeProfileImage(imageData);
    if (bytes != null) {
      child = Image.memory(
        bytes,
        key: ValueKey(imageData),
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    } else if (imageData.startsWith('http')) {
      child = Image.network(
        imageData,
        key: ValueKey(imageData),
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.darkOlive,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class OwnerImageFrame extends StatelessWidget {
  const OwnerImageFrame({
    super.key,
    required this.imageData,
    this.width,
    this.height,
    this.borderRadius = 10,
    this.placeholderIcon = Icons.image_outlined,
    this.fit = BoxFit.cover,
  });

  final String imageData;
  final double? width;
  final double? height;
  final double borderRadius;
  final IconData placeholderIcon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      color: const Color(0xFFD9D9D9),
      child: Icon(placeholderIcon, color: AppTheme.textSecondary),
    );

    final bytes = decodeOwnerImage(imageData);
    if (bytes != null) {
      child = Image.memory(
        bytes,
        key: ValueKey(imageData),
        fit: fit,
        width: width,
        height: height,
        gaplessPlayback: true,
      );
    } else if (imageData.startsWith('assets/')) {
      child = Image.asset(
        imageData,
        key: ValueKey(imageData),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: const Color(0xFFD9D9D9));
        },
      );
    } else if (imageData.startsWith('http')) {
      child = Image.network(
        imageData,
        key: ValueKey(imageData),
        fit: fit,
        width: width,
        height: height,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: const Color(0xFFD9D9D9));
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class OwnerImageSlideshow extends StatefulWidget {
  const OwnerImageSlideshow({
    super.key,
    required this.images,
    this.width,
    this.height,
    this.borderRadius = 10,
    this.fit = BoxFit.contain,
    this.interval = const Duration(seconds: 3),
  });

  final List<String> images;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final Duration interval;

  @override
  State<OwnerImageSlideshow> createState() => _OwnerImageSlideshowState();
}

class _OwnerImageSlideshowState extends State<OwnerImageSlideshow> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant OwnerImageSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) {
      _index = 0;
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncTimer() {
    _timer?.cancel();
    if (widget.images.length <= 1) return;

    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || widget.images.isEmpty) return;
      setState(() => _index = (_index + 1) % widget.images.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return OwnerImageFrame(
        imageData: '',
        width: widget.width,
        height: widget.height,
        borderRadius: widget.borderRadius,
        fit: widget.fit,
      );
    }

    final image = widget.images[_index % widget.images.length];
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          child: OwnerImageFrame(
            key: ValueKey(image),
            imageData: image,
            width: widget.width,
            height: widget.height,
            borderRadius: widget.borderRadius,
            fit: widget.fit,
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_index + 1}/${widget.images.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Uint8List? _decodeProfileImage(String imageData) {
  return decodeOwnerImage(imageData);
}

Uint8List? decodeOwnerImage(String imageData) {
  if (imageData.isEmpty || !imageData.startsWith('data:image')) {
    return null;
  }

  final commaIndex = imageData.indexOf(',');
  if (commaIndex == -1) return null;

  try {
    return base64Decode(imageData.substring(commaIndex + 1));
  } catch (_) {
    return null;
  }
}

class OwnerSectionTitle extends StatelessWidget {
  const OwnerSectionTitle({super.key, required this.title, this.color});

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: color ?? AppTheme.textDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class OwnerStatusChip extends StatelessWidget {
  const OwnerStatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class OwnerMetricCard extends StatelessWidget {
  const OwnerMetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return OwnerPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 34, color: AppTheme.darkOlive),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerQuickAction extends StatelessWidget {
  const OwnerQuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 34, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerSearchBar extends StatelessWidget {
  const OwnerSearchBar({
    super.key,
    this.hintText = 'Search',
    this.controller,
    this.onChanged,
    this.trailingIcon = Icons.filter_list,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, color: Color(0xFFD0D0D0)),
        suffixIcon: Icon(trailingIcon, color: Color(0xFFD0D0D0)),
        filled: true,
        fillColor: AppTheme.cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }
}

class OwnerBottomNav extends StatelessWidget {
  const OwnerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      Icons.home,
      Icons.people,
      Icons.edit_document,
      Icons.notifications_active,
      Icons.person,
    ];

    return Container(
      color: AppTheme.darkOlive,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 58 : 54,
                  height: isSelected ? 58 : 54,
                  decoration: BoxDecoration(
                    color: AppTheme.navButton,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : const [],
                  ),
                  child: Icon(
                    items[index],
                    color: isSelected ? Colors.black : AppTheme.darkOlive,
                    size: isSelected ? 30 : 26,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
