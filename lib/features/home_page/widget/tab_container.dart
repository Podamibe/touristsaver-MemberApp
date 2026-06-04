// ignore_for_file: deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class TabContainer extends StatelessWidget {
  // final IconData? icon;
  final String? icon;
  final String text;
  const TabContainer({super.key, this.icon, this.text = ""});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: 110,
      width: 75,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(2, 2),
                  )
                ]),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: icon!.isEmpty || icon == null
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFFF146EA),
                      )
                    : SvgPicture.network(
                        icon!,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error,
                              color: Colors.red, size: 25);
                        },
                        placeholderBuilder: (context) =>
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFFF146EA),
                        ),
                        color: const Color(0xFFF146EA),
                        fit: BoxFit.contain,
                      )),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            // text.split('').join('\u00ad'),
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class TransTabContainer extends StatelessWidget {
  final IconData? icon;
  final String text;
  final VoidCallback onPressed;
  final int? angle;
  const TransTabContainer(
      {super.key,
      this.icon,
      this.text = "",
      required this.onPressed,
      this.angle = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(2, 2),
                  )
                ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Transform.rotate(
                angle: 180 * math.pi / angle!,
                child: IconButton(
                  icon: Icon(icon),
                  color: const Color(0xFFF146EA),
                  onPressed: onPressed,
                  iconSize: 35,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            // text.split('').join('\u00ad'),
            text,
            textAlign: TextAlign.center,
            // maxLines: 2,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
