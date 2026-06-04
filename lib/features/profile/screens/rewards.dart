// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import '../../../common/widgets/custom_app_bar.dart';
// import 'package:touristsaver/generated/l10n.dart';

// import '../../../constants/global_colors.dart';
// import '../widget/custom_horizontal_table.dart';

// class RewardsScreen extends StatefulWidget {
//   static const String routeName = "/rewards-screen";
//   const RewardsScreen({super.key});

//   @override
//   State<RewardsScreen> createState() => _RewardsScreenState();
// }

// class _RewardsScreenState extends State<RewardsScreen> {
//   List<String> rowsNumber = ['10', '25', '50', '100'];
//   int pageNumber = 1;
//   int offSet = 0;
//   int limit = 10;
//   bool isSearching = false;
//   bool isClearing = false;
//   bool isPaging = false;
//   List r = [];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: CustomAppBar(
//           text: S.of(context).rewards,
//           icon: Icons.arrow_back_ios,
//           onPressed: () {
//             context.pop();
//           },
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           rewardsData(r),
//         ],
//       ),
//     );
//   }

//   //Merchant User Table Fetch Data
//   rewardsData(r) {
//     return Expanded(
//       child: Column(
//         children: [
//           //Rows Per Page, Number Selection and Pagination
//           // CustomContainerBox(
//           //   padVer: 10,
//           //   child: Row(
//           //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //     children: [
//           //       SizedBox(
//           //         width: MediaQuery.of(context).size.width / 2.3,
//           //         child: Row(
//           //           children: [
//           //             //Rows Per Page
//           //             Expanded(
//           //               child: AutoSizeText(
//           //                 "", // S.of(context).rowsPerPage,
//           //                 maxLines: 2,
//           //                 style: tableBodyTextStyle,
//           //               ),
//           //             ),

//           //             const SizedBox(width: 5),

//           //             //Number or Limit or Rows per page Selection
//           //             CustomContDropDown(
//           //               contWidth: 75,
//           //               hintText: '',
//           //               items: rowsNumber.map((e) {
//           //                 return DropdownMenuItem(
//           //                   value: e,
//           //                   child: Padding(
//           //                     padding: const EdgeInsets.only(left: 10),
//           //                     child: AutoSizeText(
//           //                       e,
//           //                       maxLines: 1,
//           //                       style: dopdownTextStyle,
//           //                     ),
//           //                   ),
//           //                 );
//           //               }).toList(),
//           //               onChanged: (newValue) {
//           //                 setState(() {
//           //                   // isPaging = true;
//           //                   // limit = int.parse(newValue.toString());
//           //                   // pageNumber = 1;
//           //                   // transactionDetailRes = getTransactionDetailRes();
//           //                 });
//           //               },
//           //               valueObject: limit.toString(),
//           //               dropdownWidth: 75,
//           //             ),
//           //           ],
//           //         ),
//           //       ),
//           //       const SizedBox(width: 10),

//           //       //Showing numbers
//           //       Expanded(
//           //         child: Row(
//           //           mainAxisAlignment: MainAxisAlignment.end,
//           //           children: [
//           //             //Showing numbers
//           //             Expanded(
//           //               child: AutoSizeText(
//           //                 r.data!.isEmpty
//           //                     ? '0 - 0 of 0'
//           //                     : '${r.page == 1 ? 1 : (pageNumber - 1) * limit + 1} - ${r.page == 1 ? r.count : (pageNumber - 1) * limit + r.count!} of ${r.totalCount}',
//           //                 maxLines: 1,
//           //                 style: tableBodyTextStyle,
//           //               ),
//           //             ),

//           //             const SizedBox(width: 10),

//           //             //pagination
//           //             //Left Arrow
//           //             InkWell(
//           //               onTap: offSet == 0 || r.page == 1
//           //                   ? () {}
//           //                   : () {
//           //                       setState(() {
//           //                         isPaging = true;
//           //                         pageNumber = pageNumber - 1;
//           //                         offSet = offSet - 10;
//           //                         // transactionDetailRes =
//           //                         //     getTransactionDetailRes();
//           //                       });
//           //                     },
//           //               child: Icon(
//           //                 Icons.arrow_circle_left,
//           //                 size: 30,
//           //                 color: r.page == 1
//           //                     ? GlobalColors.paleGray
//           //                     : GlobalColors.textColor,
//           //               ),
//           //             ),

//           //             const SizedBox(width: 10),

//           //             //Right Arrow
//           //             InkWell(
//           //               onTap: r.hasMore == false
//           //                   ? () {}
//           //                   : () {
//           //                       setState(() {
//           //                         isPaging = true;
//           //                         pageNumber = pageNumber + 1;
//           //                         offSet = offSet + 10;
//           //                         // transactionDetailRes =
//           //                         //     getTransactionDetailRes();
//           //                       });
//           //                     },
//           //               child: Icon(
//           //                 Icons.arrow_circle_right,
//           //                 size: 30,
//           //                 color: r.hasMore == false
//           //                     ? GlobalColors.paleGray
//           //                     : GlobalColors.textColor,
//           //               ),
//           //             ),
//           //           ],
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           //  Table
//           rewardsDataTable(r)
//         ],
//       ),
//     );
//   }

// //Transaction Data Table
//   rewardsDataTable(rData) {
//     return CustomHorizontalTable(
//       scrollPhysics: const AlwaysScrollableScrollPhysics(),
//       leftHandSideColumnWidth: 150.w,
//       rightHandSideColumnWidth: 450.w,
//       headerWidgets: [
//         Row(
//           children: [
//             Expanded(flex: 2, child: TableHeader(label: S.of(context).sn)),
//             Expanded(
//                 flex: 6, child: TableHeader(label: S.of(context).schemaName)),
//           ],
//         ),
//         TableHeader(label: S.of(context).rewardScahemaType, width: 150.w),
//         TableHeader(label: S.of(context).reward, width: 150.w),
//         TableHeader(label: S.of(context).rewardRerceivedDate, width: 150.w),
//       ],
//       itemCount: 1,
//       // rData.data!.isEmpty ? 1 : rData.data!.length,
//       leftSideItemBuilder: (BuildContext context, int index) {
//         return
//             // rData.data!.isEmpty
//             //     ? AutoSizeText(
//             //         '',
//             //         maxLines: 1,
//             //         style: tableNoDataTextStyle,
//             //       )
//             //     :
//             Row(
//           children: [
//             Expanded(
//               flex: 2,
//               child: TableBody(
//                 sendIndex: index,
//                 text: '${index + 1 + (pageNumber - 1) * limit}',
//               ),
//             ),
//             //Schema name
//             Expanded(
//               flex: 6,
//               child: TableBody(
//                 text: '-',
//                 sendIndex: index,
//                 width: 120.w,
//               ),
//             ),
//           ],
//         );
//       },
//       rightSideItemBuilder: (BuildContext context, int index) {
//         return
//             //  rData.data!.isEmpty
//             //     ? Align(
//             //         alignment: Alignment.centerLeft,
//             //         child: Padding(
//             //           padding: const EdgeInsets.all(20),
//             //           child: AutoSizeText(
//             //             S.of(context).noDataFound,
//             //             maxLines: 1,
//             //             style: tableNoDataTextStyle,
//             //           ),
//             //         ),
//             //       )
//             //     :
//             Container(
//           color: GlobalColors.appGreyBackgroundColor,
//           child: Row(
//             children: [
//               TableBody(
//                 text: '-',
//                 sendIndex: index,
//                 width: 150.w,
//               ),
//               TableBody(
//                 text: '-',
//                 sendIndex: index,
//                 width: 150.w,
//               ),
//               TableBody(
//                 text: '-',
//                 sendIndex: index,
//                 width: 150.w,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
