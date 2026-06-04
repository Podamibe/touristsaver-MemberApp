import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';

class CustomAppBar extends StatelessWidget {
  final String text;
  final IconData? icon;
  final IconData? icon1;
  final IconData? icon2;
  final VoidCallback? onPressed;
  final VoidCallback? onPressed1;
  final VoidCallback? onPressed2;
  final PreferredSizeWidget? tabs;
  final Color? icon2Color;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool reserveEmptyActions;
  final double? leadingWidth;
  final double? titleSpacing;

  const CustomAppBar({
    super.key,
    required this.text,
    this.icon,
    this.icon1,
    this.icon2,
    this.onPressed,
    this.onPressed1,
    this.onPressed2,
    this.tabs,
    this.icon2Color,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.reserveEmptyActions = true,
    this.leadingWidth,
    this.titleSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
            color: GlobalColors.appGreyBackgroundColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(2, 2))
            ]),
      ),
      elevation: 0.0,
      leadingWidth: leadingWidth,
      titleSpacing: titleSpacing,
      leading: IconButton(
        icon: Icon(icon),
        color: Colors.black.withValues(alpha: 0.8),
        onPressed: onPressed,
        iconSize: 20,
      ),

      title: Tooltip(
          message: text,
          child: AutoSizeText(
            text,
            // 👉 Apply the color if it exists, otherwise use default
            style: textColor != null
                ? appbarTitleStyle.copyWith(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  )
                : appbarTitleStyle,
            overflow: TextOverflow.ellipsis,
          )),

      centerTitle: true,

      // For icon is right side
      actions: reserveEmptyActions
          ? [
              IconButton(
                onPressed: onPressed1,
                icon: Icon(icon1),
                color: GlobalColors.appColor1,
              ),
              IconButton(
                onPressed: onPressed2,
                icon: Icon(icon2),
                color: icon2Color,
                iconSize: 30,
              ),
            ]
          : [
              if (icon1 != null)
                IconButton(
                  onPressed: onPressed1,
                  icon: Icon(icon1),
                  color: GlobalColors.appColor1,
                ),
              if (icon2 != null)
                IconButton(
                  onPressed: onPressed2,
                  icon: Icon(icon2),
                  color: icon2Color,
                  iconSize: 30,
                ),
            ],

      bottom: tabs,
    );
  }
}

//Custom App Bar with infoIcon in actions
class CustomAppBar1 extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final VoidCallback? onInfoTap;
  final String? infoImage;
  final PreferredSizeWidget? tabs;
  final Color? textColor; // 👉 Added here too just in case

  const CustomAppBar1({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.onInfoTap,
    this.infoImage,
    this.tabs,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
            color: GlobalColors.appGreyBackgroundColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(2, 2))
            ]),
      ),
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(icon),
        color: Colors.black.withValues(alpha: 0.8),
        onPressed: onPressed,
        iconSize: 20,
      ),
      title: Tooltip(
          message: text,
          child: AutoSizeText(
            text,
            style: textColor != null
                ? appbarTitleStyle.copyWith(color: textColor)
                : appbarTitleStyle,
            overflow: TextOverflow.ellipsis,
          )),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: onInfoTap,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ClipRRect(
              child: infoImage == null
                  ? Image.asset(
                      "assets/images/info.png",
                    )
                  : Image.asset(
                      infoImage!,
                      color: GlobalColors.appColor,
                      height: 30,
                      width: 30,
                    ),
            ),
          ),
        ),
      ],
      bottom: tabs,
    );
  }
}

//Custom App Bar with delete Icon in actions
class CustomAppBar2 extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Widget? deleteWidget;
  final VoidCallback? onDeleteTap;
  final PreferredSizeWidget? tabs;
  final Color? textColor; // 👉 Added here too

  const CustomAppBar2({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.deleteWidget,
    this.onDeleteTap,
    this.tabs,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
            color: GlobalColors.appGreyBackgroundColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(2, 2))
            ]),
      ),
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(icon),
        color: Colors.black.withValues(alpha: 0.8),
        onPressed: onPressed,
        iconSize: 20,
      ),
      title: Tooltip(
          message: text,
          child: AutoSizeText(
            text,
            style: textColor != null
                ? appbarTitleStyle.copyWith(color: textColor)
                : appbarTitleStyle,
            overflow: TextOverflow.ellipsis,
          )),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: onDeleteTap,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: deleteWidget,
          ),
        ),
      ],
      bottom: tabs,
    );
  }
}
