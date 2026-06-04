import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/constants/style.dart';
import '../../../constants/global_colors.dart';
import 'package:touristsaver/generated/l10n.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.05,
      // padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      decoration: BoxDecoration(
          color: GlobalColors.appWhiteBackgroundColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            )
          ]),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/wifi-off.png',
              height: 100.h,
              width: 100.w,
            ),
            SizedBox(height: 30.h),
            Text(
              S.of(context).youreCurrentlyOfflineCheckYourConnectionAndTryAgain,
              // "You're currently offline.\n Check your connection and try again.",
              textAlign: TextAlign.center,
              style: locationStyle.copyWith(fontSize: 16),
            ),

            //  CustomButton(onPressed: () {}, text: 'Refresh')
          ],
        ),
      ),
    );
  }
}

class NoInternetLoader extends StatelessWidget {
  const NoInternetLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: GlobalColors.loaderColor,
        strokeWidth: 1,
      ),
    );
  }
}
// class NoInternetScreen extends StatefulWidget {
//   const NoInternetScreen({super.key});

//   @override
//   State<NoInternetScreen> createState() => _NoInternetScreenState();
// }

// class _NoInternetScreenState extends State<NoInternetScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(80.0),
//         child: Column(
//           children: [
//             SizedBox(
//                 height: 200,
//                 width: 200,
//                 child: Image.asset('assets/images/no-int.png')),
//             const SizedBox(
//               height: 10,
//             ),
//             Text(
//               'No Internet Connection !!',
//               style: appbarTitleStyle,
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             // CustomButton(onPressed: () {}, text: 'Refresh')
//           ],
//         ),
//       ),
//     );
//   }
// }
