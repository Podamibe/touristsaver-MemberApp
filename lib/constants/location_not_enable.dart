import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/common/services/location_service.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

class LocationNotEnabled extends StatefulWidget {
  final String text;

  const LocationNotEnabled({super.key, required this.text});

  @override
  State<LocationNotEnabled> createState() => _LocationNotEnabledState();
}

class _LocationNotEnabledState extends State<LocationNotEnabled> {
  // bool accessConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fill,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.02,
        padding: const EdgeInsets.only(
            top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
            color: GlobalColors.appWhiteBackgroundColor,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  offset: const Offset(2, 2),
                  spreadRadius: 1,
                  blurRadius: 4)
            ]),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Image.asset(
              "assets/images/map_button1.png",
              height: 50,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: AutoSizeText(widget.text,
                  textAlign: TextAlign.center, style: locationStyle),
            ),
            const SizedBox(height: 10),

            // Enable Access button
            AppVariables.accessConfirmed
                ? const CustomButtonWithCircular()
                : CustomButton(
                    text: S.of(context).enableAccess,
                    //"Enable Access",
                    onPressed: () async {
                      setState(() {
                        AppVariables.accessConfirmed = true;
                      });
                      await LocationService()
                          .enableLocationAndFetchCountry()
                          .then((value) {
                        if (value == false) {
                          setState(() {
                            AppVariables.accessConfirmed = false;
                          });
                        }
                      });
                    }),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
