import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/global_colors.dart';
import '../../../constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

class MyCharityWidget extends StatelessWidget {
  const MyCharityWidget({
    super.key,
    this.charityName,
  });
  final String? charityName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      child: ListTile(
        tileColor: GlobalColors.appWhiteBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          // Charity Name
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AutoSizeText(
                '${S.of(context).yourCharity}: ',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              AutoSizeText(
                charityName ?? 'Not selected',
                style: profileListStyle.copyWith(
                    color: charityName == null
                        ? GlobalColors.gray
                        : GlobalColors.appColor1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
