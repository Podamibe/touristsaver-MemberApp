import 'package:flutter/material.dart';

class TouristSaverLoadingView extends StatelessWidget {
  const TouristSaverLoadingView({
    super.key,
    this.height,
    this.spinnerSize = 30,
    this.strokeWidth = 3,
  });

  static const Color _brandBlue = Color(0xFF0009FE);

  final double? height;
  final double spinnerSize;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final double resolvedHeight =
        height ?? MediaQuery.sizeOf(context).height * 0.55;

    return SizedBox(
      width: double.infinity,
      height: resolvedHeight,
      child: Center(
        child: SizedBox(
          width: spinnerSize,
          height: spinnerSize,
          child: CircularProgressIndicator(
            color: _brandBlue,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}
