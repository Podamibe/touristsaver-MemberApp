import 'package:flutter/material.dart';
import 'package:touristsaver/constants/global_colors.dart';

class GradientInImage extends StatelessWidget {
  final Widget child;
  const GradientInImage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            GlobalColors.appColor,
            GlobalColors.appColor1,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop, //to blend the color
      child: child,
    );
  }
}
