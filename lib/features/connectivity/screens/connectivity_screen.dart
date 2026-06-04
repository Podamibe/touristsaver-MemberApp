import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

import '../cubit/internet_cubit.dart';

class NoConnectivityScreen extends StatefulWidget {
  const NoConnectivityScreen({super.key});

  @override
  State<NoConnectivityScreen> createState() => _NoConnectivityScreenState();
}

class _NoConnectivityScreenState extends State<NoConnectivityScreen> {
  @override
  Widget build(BuildContext context) {
    final internetProvider = context.read<ConnectivityCubit>();
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 80.h,
            ),
            Image.asset(
              'assets/images/wifi-off.png',
              height: 150,
              width: 150,
            ),
            SizedBox(height: 30.h),
            Text(
              S.of(context).youreCurrentlyOfflineCheckYourConnectionAndTryAgain,
              //     "You're currently offline.\n Check your connection and try again.",
              textAlign: TextAlign.center,
              style: locationStyle.copyWith(fontSize: 20),
            ),
            SizedBox(height: 20),
            TextButton(
                onPressed: () {
                  internetProvider.checkConnectivity();
                },
                child: Text('Refresh', style: noteTextStyle)),
          ],
        ),
      ),
    );
  }
}


///
// class NoConnectivityScreen extends StatelessWidget {
//   const NoConnectivityScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.signal_wifi_off, size: 100),
//               const SizedBox(height: 20),
//               const Text(
//                 'No internet connection',
//                 style: TextStyle(fontSize: 20),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('Try again'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }