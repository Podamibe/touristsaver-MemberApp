import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/merchant_distance.dart';
import 'package:touristsaver/common/widgets/merchant_discount_badge.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';

import 'custom_loader.dart';

class SmallTabContainer extends StatelessWidget {
  final VoidCallback smallOnTap;
  final String smallImage;
  final String smallMerchantName;
  final String smallDiscountGiven;
  final double? distance;

  const SmallTabContainer({
    super.key,
    required this.smallOnTap,
    required this.smallImage,
    required this.smallMerchantName,
    required this.smallDiscountGiven,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: smallOnTap,
      child: Container(
        decoration: BoxDecoration(
            color: GlobalColors.appWhiteBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  offset: const Offset(2, 2),
                  spreadRadius: 1,
                  blurRadius: 1)
            ]),
        child: Column(
          children: [
            // Image
            Expanded(
              flex: 8,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    topLeft: Radius.circular(10.0)),
                child: CachedNetworkImage(
                  imageUrl: smallImage,
                  fit: BoxFit.cover,
                  width: size.width / 1.3,
                  placeholder: (context, url) {
                    return const Center(
                        child: FittedBox(child: CustomAllLoader1()));
                  },
                  errorWidget: (context, url, error) =>
                      Center(child: Image.asset('assets/images/no_image.jpg')),
                ),
              ),
            ),

            // Merchant Name
            Expanded(
              flex: 3,
              child: Tooltip(
                message: smallMerchantName,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5, left: 5, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: AutoSizeText(
                      smallMerchantName,
                      style: merchantNameStyle.copyWith(fontSize: 15.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            if (distance != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 5),
                  child: Text(
                    formatMerchantDistance(distance),
                    style: merchantNameStyle.copyWith(
                      fontSize: 15.sp,
                      color: const Color(0xFF63708A),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: size.width,
              height: 1.0,
              child: ColoredBox(color: Colors.grey.withValues(alpha: 0.5)),
            ),

            // Discount
            Expanded(
              flex: 2,
              child: Container(
                // height: 40.h,
                decoration: BoxDecoration(
                  color: GlobalColors.appGreyBackgroundColor
                      .withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                ),
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MerchantDiscountBadge(discount: smallDiscountGiven),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NewSmallTabContainer extends StatelessWidget {
  final VoidCallback newSmallOnTap;
  final String newSmallImage;
  final String newSmallMerchantName;
  final String newSmallDiscountGiven;
  const NewSmallTabContainer({
    super.key,
    required this.newSmallOnTap,
    required this.newSmallImage,
    required this.newSmallMerchantName,
    required this.newSmallDiscountGiven,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: newSmallOnTap,
      child: Container(
        decoration: BoxDecoration(
            color: GlobalColors.appWhiteBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  offset: const Offset(2, 2),
                  spreadRadius: 1,
                  blurRadius: 1)
            ]),
        child: Column(
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      topLeft: Radius.circular(10.0)),
                  child: CachedNetworkImage(
                    imageUrl: newSmallImage,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width / 1.3,
                    placeholder: (context, url) {
                      return const Center(
                          child: FittedBox(child: CustomAllLoader1()));
                    },
                    errorWidget: (context, url, error) => Center(
                        child: Image.asset('assets/images/no_image.jpg')),
                  ),
                ),
              ),
            ),
            // Merchant Name
            Expanded(
              flex: 2,
              child: Tooltip(
                message: newSmallMerchantName,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 5.0, left: 5.0, top: 10.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: AutoSizeText(
                      newSmallMerchantName,
                      style: merchantNameStyle.copyWith(fontSize: 15.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),

            // Small Line
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 1.0,
              child: ColoredBox(color: Colors.grey.withValues(alpha: 0.5)),
            ),

            // Discount
            Container(
              height: 40,
              decoration: BoxDecoration(
                color:
                    GlobalColors.appGreyBackgroundColor.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0)),
              ),
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: MerchantDiscountBadge(discount: newSmallDiscountGiven),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NewSmallTabContainerWithFav extends StatelessWidget {
  final VoidCallback newSmallOnTap;
  final String newSmallImage;
  final String newSmallMerchantName;
  final String newSmallDiscountGiven;
  final VoidCallback newFavouriteTap;
  final bool newIsFavouriteTap;

  const NewSmallTabContainerWithFav({
    super.key,
    required this.newSmallOnTap,
    required this.newSmallImage,
    required this.newSmallMerchantName,
    required this.newSmallDiscountGiven,
    required this.newFavouriteTap,
    required this.newIsFavouriteTap,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                offset: const Offset(2, 2),
                spreadRadius: 1,
                blurRadius: 1)
          ]),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: newSmallOnTap,
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0)),
                      child: CachedNetworkImage(
                        imageUrl: newSmallImage,
                        fit: BoxFit.cover,
                        width: size.width / 1.3,
                        placeholder: (context, url) {
                          return const Center(
                              child: FittedBox(child: CustomAllLoader1()));
                        },
                        errorWidget: (context, url, error) => Center(
                          child: Image.asset('assets/images/no_image.jpg'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Tooltip(
                      message: newSmallMerchantName,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 5.0, left: 5.0, top: 10.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: AutoSizeText(
                            newSmallMerchantName,
                            style: merchantNameStyle.copyWith(fontSize: 15.sp),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Small Line
          SizedBox(
            width: size.width,
            height: 1.0,
            child: ColoredBox(color: Colors.grey.withValues(alpha: 0.5)),
          ),

          // Discount
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: GlobalColors.appGreyBackgroundColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
            ),
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: MerchantDiscountBadge(
                    discount: newSmallDiscountGiven,
                  ),
                ),

                //Favourite Part
                AppVariables.accessToken == null
                    ? const SizedBox()
                    : Flexible(
                        child: InkWell(
                          onTap: newFavouriteTap,
                          child: newIsFavouriteTap == true
                              ? const Icon(
                                  Icons.favorite,
                                  color: GlobalColors.appColor,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                  color: GlobalColors.appColor,
                                ),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
