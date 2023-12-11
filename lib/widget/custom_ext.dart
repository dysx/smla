import 'package:flutter/material.dart';

/// 将文字转换成Image
extension StrExt on String {
  ImageView get toImage {
    return ImageView(name: this);
  }
}

// ignore: must_be_immutable
class ImageView extends StatelessWidget {
  ImageView({
    Key? key,
    required this.name,
    this.width,
    this.height,
    this.color,
    this.opacity = 1,
    this.fit,
    this.onTap,
    this.onDoubleTap,
  }) : super(key: key);
  final String name;
  double? width;
  double? height;
  Color? color;
  double opacity;
  BoxFit? fit;
  Function()? onTap;
  Function()? onDoubleTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            name,
            width: width,
            height: height,
            color: color,
            fit: fit,
          ),
        ),
      );
}
