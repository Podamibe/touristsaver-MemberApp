import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/widgets/merchant_distance.dart';
import 'package:touristsaver/common/widgets/merchant_discount_badge.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';

import '../../../common/widgets/custom_loader.dart';

class BigTabContainer extends StatelessWidget {
  final String bigDiscountGiven;
  final String bigMerchantName;
  final String bigImage;
  final VoidCallback bigOnTap;
  final String? bigLogo; //
  final double? bigDistance;
  final Widget? child;
  const BigTabContainer({
    super.key,
    required this.bigDiscountGiven,
    required this.bigMerchantName,
    required this.bigImage,
    required this.bigOnTap,
    this.bigLogo,
    this.child,
    this.bigDistance,
  });

  @override
  Widget build(BuildContext context) {
    double contWidth = (MediaQuery.of(context).size.width - 34) / 2;
    // double contImgHeight = contWidth / 2;
    return GestureDetector(
      onTap: bigOnTap,
      child: Container(
        width: contWidth,
        margin: const EdgeInsets.only(bottom: 5.0),
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
              flex: 8,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    topLeft: Radius.circular(10.0)),
                child: CachedNetworkImage(
                  imageUrl: bigImage,
                  fit: BoxFit.cover,
                  width: contWidth,
                  placeholder: (context, url) {
                    return const Center(
                        child: FittedBox(child: CustomAllLoader1()));
                  },
                  errorWidget: (context, url, error) => Center(
                      child: Image.asset(
                    'assets/images/no_image.jpg',
                  )),
                ),
              ),
            ),

            //Merchant Name
            Expanded(
              flex: 3,
              child: Tooltip(
                message: bigMerchantName,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: AutoSizeText(
                      bigMerchantName,
                      style: merchantNameStyle,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),

            // SizedBox(
            //   child: child,
            // ),
            // Small Line
            SizedBox(
              width: contWidth,
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
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 4,
                      child: AutoSizeText(
                        formatMerchantDistance(bigDistance),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: merchantNameStyle.copyWith(
                          color: const Color(0xFF63708A),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 5,
                      child: MerchantDiscountBadge(
                        discount: bigDiscountGiven,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NewBigTabContainerWithFav extends StatelessWidget {
  final String newbigDiscountGiven;
  final String newbigMerchantName;
  final String newbigImage;
  final VoidCallback newbigOnTap;
  final String newbigLogo;
  final VoidCallback newbigFavouriteTap;
  final bool newbigIsFavouriteTap;
  const NewBigTabContainerWithFav({
    super.key,
    required this.newbigDiscountGiven,
    required this.newbigMerchantName,
    required this.newbigImage,
    required this.newbigOnTap,
    required this.newbigLogo,
    required this.newbigFavouriteTap,
    required this.newbigIsFavouriteTap,
  });

  @override
  Widget build(BuildContext context) {
    double contWidth = MediaQuery.of(context).size.width / 1.6;
    double contImgHeight = contWidth / 2;
    return Container(
      margin: const EdgeInsets.only(bottom: 5.0),
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
              onTap: newbigOnTap,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0)),
                      child: CachedNetworkImage(
                        imageUrl: newbigImage,
                        fit: BoxFit.cover,
                        width: contWidth,
                        height: contImgHeight,
                        placeholder: (context, url) {
                          return const Center(
                              child: FittedBox(child: CustomAllLoader1()));
                        },
                        errorWidget: (context, url, error) => Center(
                            child: Image.asset('assets/images/no_image.jpg')),
                      ),
                    ),
                  ),

                  // Logo and Merchant Name
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: contWidth,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ClipRRect(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: CachedNetworkImage(
                                    imageUrl: newbigLogo,
                                    fit: BoxFit.contain,
                                    height: 70,
                                    placeholder: (context, url) {
                                      return const Center(
                                          child: FittedBox(
                                              child: CustomAllLoader1()));
                                    },
                                    errorWidget: (context, url, error) =>
                                        Center(
                                      child: Image.asset(
                                          'assets/images/no_image.jpg'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            flex: 2,
                            child: Tooltip(
                              message: newbigMerchantName,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: AutoSizeText(
                                    newbigMerchantName,
                                    style: merchantNameStyle,
                                    maxLines: 2,
                                    textAlign: TextAlign.left,
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
                ],
              ),
            ),
          ),

          // Discount
          Container(
            decoration: BoxDecoration(
              color: GlobalColors.appGreyBackgroundColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: SizedBox(
              width: contWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: MerchantDiscountBadge(discount: newbigDiscountGiven),
                  ),

                  const SizedBox(width: 5),

                  //Favourite Icon
                  if (AppVariables.accessToken != null)
                    InkWell(
                      onTap: newbigFavouriteTap,
                      child: newbigIsFavouriteTap == true
                          ? const Icon(
                              Icons.favorite,
                              color: GlobalColors.appColor,
                            )
                          : const Icon(
                              Icons.favorite_border,
                              color: GlobalColors.appColor,
                            ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
