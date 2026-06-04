// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:touristsaver/common/widgets/custom_app_bar.dart';
// import 'package:touristsaver/common/widgets/custom_loader.dart';
// import 'package:touristsaver/common/widgets/error.dart';
// import 'package:touristsaver/common/widgets/not_available.dart';
// import 'package:touristsaver/constants/app_text.dart';
// import 'package:touristsaver/constants/date_helper.dart';
// import 'package:touristsaver/constants/decimal_remove.dart';
// import 'package:touristsaver/constants/fixed_decimal.dart';
// import 'package:touristsaver/constants/global_colors.dart';
// import 'package:touristsaver/constants/style.dart';
// import 'package:touristsaver/features/transaction/bloc/transac_blocs.dart';
// import 'package:touristsaver/features/transaction/bloc/transac_events.dart';
// import 'package:touristsaver/features/transaction/bloc/transac_states.dart';
// import 'package:touristsaver/features/transaction/services/dio_transaction.dart';
// import 'package:touristsaver/models/response/transaction_res.dart';

// class TransactionScreen extends StatefulWidget {
//   static const String routeName = '/statement';
//   final double uniBalance;
//   const TransactionScreen({super.key, required this.uniBalance});
//   // const StatementScreen({super.key});

//   @override
//   State<TransactionScreen> createState() => _TransactionScreenState();
// }

// class _TransactionScreenState extends State<TransactionScreen> {
//   final dateKey = GlobalKey<FormState>();
//   final TextEditingController latestDateController = TextEditingController();
//   final TextEditingController previousDateController = TextEditingController();

//   // // For First Design
//   // List<String> selectDays = [
//   //   '7 Days',
//   //   '14 Days',
//   //   '24 Days',
//   //   '60 Days',
//   //   '100 Days',
//   //   '120 Days',
//   //   '140 Days',
//   // ];
//   // String? daySelected;

//   //for formatting dateTime
//   DateFormat dateFormatTime = DateFormat(" HH:mm a"); //Example: 4:30
//   DateFormat dateFormatDate = DateFormat.yMd(); //Example: 1/1/2023
//   DateFormat dateFormatweek = DateFormat('EEEE'); //Example: Sunday, Moday
//   DateFormat stringToDateTime = DateFormat('yyyy-MM-dd'); //Example: 2023-01-01

// // For storing the transactionDate
//   List<String>? availableDate = [];

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // latestDateController.text = stringToDateTime.format(DateTime.now());
//       // previousDateController.text = stringToDateTime.format(DateTime.now());
//       setState(() {});
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: CustomAppBar(
//           text: transaction,
//           icon: Icons.arrow_back_ios,
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: LayoutBuilder(
//           builder: (BuildContext context, BoxConstraints constraints) {
//         // return SingleChildScrollView(
//         //   child: Column(
//         //     children: [
//         //       // const SizedBox(height: 10),
//         //       firstDesign(context, constraints),
//         //       const SizedBox(height: 40),
//         //       secondDesign(context, constraints),
//         //     ],
//         //   ),
//         // );

//         return SingleChildScrollView(
//           child: secondDesign(context, constraints),
//         );
//       }),

//       //Floating action button for filtering
//       floatingActionButton: FloatingActionButton.extended(
//         label: AutoSizeText(
//           'Filter',
//           style: transUni.copyWith(color: Colors.white),
//         ),
//         backgroundColor: GlobalColors.appColor1,
//         onPressed: () {
//           filterTransac();
//         },
//         icon: const Icon(
//           Icons.filter_list_rounded,
//           size: 25,
//         ),
//       ),
//     );
//   }

//   // firstDesign(BuildContext context, BoxConstraints constraints) {
//   //   return Container(
//   //     width: MediaQuery.of(context).size.width,
//   //     height: constraints.maxHeight / 1,
//   //     decoration: const BoxDecoration(
//   //       gradient: LinearGradient(
//   //         begin: Alignment.topRight,
//   //         end: Alignment.topLeft,
//   //         colors: [
//   //           GlobalColors.appColor,
//   //           GlobalColors.appColor1,
//   //         ],
//   //       ),
//   //     ),
//   //     child: Column(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       children: [
//   //         // Universal Piiink
//   //         Padding(
//   //           padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
//   //           child: AutoSizeText(
//   //             avaUni,
//   //             style: transUni,
//   //           ),
//   //         ),
//   //         AutoSizeText(
//   //           '${toFixed2DecimalPlaces(10.0)} Piiinks',
//   //           style: transUniBal,
//   //         ),
//   //         const SizedBox(height: 10),
//   //         //TopUp and Transfer Icon and ViewAll
//   //         Row(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: [
//   //             //TopUp
//   //             TransTabContainer(
//   //               icon: Icons.add_box_rounded,
//   //               text: topUpTitle,
//   //               onPressed: () {
//   //                 Navigator.pushNamed(context, TopUpScreen.routeName);
//   //               },
//   //             ),
//   //             const SizedBox(width: 20),
//   //             //Transfer
//   //             TransTabContainer(
//   //               icon: Icons.send,
//   //               text: 'Transfer',
//   //               onPressed: () {
//   //                 Navigator.pushNamed(context, TransferPiiinks.routeName);
//   //               },
//   //               angle: 100,
//   //             ),
//   //             const SizedBox(width: 20),
//   //             //View All
//   //             TransTabContainer(
//   //               icon: Icons.visibility,
//   //               text: 'View All',
//   //               onPressed: () {},
//   //             ),
//   //           ],
//   //         ),
//   //         const SizedBox(height: 10),
//   //         //Transaction
//   //         Expanded(
//   //           child: Container(
//   //             width: MediaQuery.of(context).size.width,
//   //             decoration: BoxDecoration(
//   //               borderRadius: const BorderRadius.only(
//   //                   topLeft: Radius.circular(35.0),
//   //                   topRight: Radius.circular(35.0)),
//   //               color: GlobalColors.appWhiteBackgroundColor,
//   //               boxShadow: [
//   //                 BoxShadow(
//   //                   color: Colors.white.withValues(alpha: 0.2),
//   //                   blurRadius: 4,
//   //                   spreadRadius: 7,
//   //                   offset: const Offset(2, 2),
//   //                 )
//   //               ],
//   //             ),
//   //             child: Column(
//   //               children: [
//   //                 //Choosing the days
//   //                 Padding(
//   //                   padding: const EdgeInsets.symmetric(
//   //                       horizontal: 15, vertical: 15),
//   //                   child: Row(
//   //                     children: [
//   //                       Expanded(
//   //                         child: AutoSizeText(
//   //                           'Your Transactions',
//   //                           style: topicStyle,
//   //                         ),
//   //                       ),
//   //                       Expanded(
//   //                         child: Align(
//   //                           alignment: Alignment.centerRight,
//   //                           child: DropdownButtonHideUnderline(
//   //                             child: DropdownButton2(
//   //                               hint: AutoSizeText(
//   //                                 '7 Days',
//   //                                 style: dopdownTextStyle,
//   //                               ),
//   //                               icon: const Icon(
//   //                                 Icons.expand_more,
//   //                                 color: GlobalColors.appColor,
//   //                               ),
//   //                               iconOnClick: const Icon(
//   //                                 Icons.expand_less,
//   //                                 color: GlobalColors.appColor,
//   //                               ),
//   //                               items: selectDays.map((e) {
//   //                                 return DropdownMenuItem(
//   //                                   value: e,
//   //                                   child: AutoSizeText(
//   //                                     e,
//   //                                     style: TextStyle(
//   //                                       fontSize: 15,
//   //                                       fontWeight: FontWeight.w500,
//   //                                       color: Colors.black.withValues(alpha: 0.7),
//   //                                     ),
//   //                                   ),
//   //                                 );
//   //                               }).toList(),
//   //                               onChanged: (newVal) {
//   //                                 setState(() {
//   //                                   daySelected = newVal;
//   //                                 });
//   //                               },
//   //                               value: daySelected,
//   //                               itemHeight: 35,
//   //                               dropdownWidth: 150,
//   //                             ),
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ),
//   //                 //Showing Transaction
//   //                 Expanded(
//   //                   child: ScrollConfiguration(
//   //                     behavior: const ScrollBehavior(),
//   //                     child: ListView.separated(
//   //                       physics: const NeverScrollableScrollPhysics(),
//   //                       shrinkWrap: true,
//   //                       padding: const EdgeInsets.only(
//   //                           left: 10.0, right: 10.0, bottom: 30.0),
//   //                       separatorBuilder: (context, index) {
//   //                         return const SizedBox(height: 20);
//   //                       },
//   //                       itemCount: 4,
//   //                       itemBuilder: (context, index) {
//   //                         return Align(
//   //                           alignment: Alignment.center,
//   //                           child: Column(
//   //                             crossAxisAlignment: CrossAxisAlignment.start,
//   //                             children: [
//   //                               //Date
//   //                               AutoSizeText(
//   //                                 '2023/01/19',
//   //                                 style: transUni.copyWith(color: Colors.grey),
//   //                               ),
//   //                               const SizedBox(height: 5),
//   //                               FittedBox(
//   //                                 fit: BoxFit.fill,
//   //                                 child: Container(
//   //                                   width:
//   //                                       MediaQuery.of(context).size.width / 1,
//   //                                   padding: const EdgeInsets.all(10.0),
//   //                                   decoration: BoxDecoration(
//   //                                     gradient: const LinearGradient(
//   //                                       begin: Alignment.topRight,
//   //                                       end: Alignment.topLeft,
//   //                                       colors: [
//   //                                         GlobalColors.appColor,
//   //                                         GlobalColors.appColor1,
//   //                                       ],
//   //                                     ),
//   //                                     borderRadius: BorderRadius.circular(5.0),
//   //                                   ),
//   //                                   child: Column(
//   //                                     children: [
//   //                                       Row(
//   //                                         children: [
//   //                                           //Title and Sub Title
//   //                                           SizedBox(
//   //                                             width: MediaQuery.of(context)
//   //                                                     .size
//   //                                                     .width /
//   //                                                 1.5,
//   //                                             child: Column(
//   //                                               crossAxisAlignment:
//   //                                                   CrossAxisAlignment.start,
//   //                                               children: [
//   //                                                 //Title
//   //                                                 AutoSizeText(
//   //                                                   'Top Up',
//   //                                                   style: transConTitl,
//   //                                                 ),
//   //                                                 const SizedBox(height: 5),
//   //                                                 //Sub Title
//   //                                                 AutoSizeText(
//   //                                                   'Transfer',
//   //                                                   style: transConSubTitl,
//   //                                                 ),
//   //                                               ],
//   //                                             ),
//   //                                           ),
//   //                                           //Transaction Piiink
//   //                                           Expanded(
//   //                                             child: AutoSizeText(
//   //                                               toFixed2DecimalPlaces(10.0),
//   //                                               textAlign: TextAlign.end,
//   //                                               style: transUniBal.copyWith(
//   //                                                   fontSize: 20.sp),
//   //                                             ),
//   //                                           ),
//   //                                         ],
//   //                                       )
//   //                                     ],
//   //                                   ),
//   //                                 ),
//   //                               ),
//   //                             ],
//   //                           ),
//   //                         );
//   //                       },
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   secondDesign(BuildContext context, BoxConstraints constraints) {
//     // // To know how many transactions are available in same day or date
//     // List<String>? sameDayDateTransactionList = [];

//     // //Storing the transaction data according to its dataTime
//     // // Map<String, dynamic>? dayDateAllTransaction = [];
//     // List<Datum>? dayDateAllTransaction = [];

//     return BlocProvider(
//       lazy: false,
//       create: (context) => TransacBloc(
//         RepositoryProvider.of<DioTransaction>(context),
//         // latestDate!,
//         '2023-01-24',
//         // previousDate!,
//         '2022-10-20',
//       )..add(LoadTransacEvent()),
//       child: BlocBuilder<TransacBloc, TransacState>(
//         builder: (context, state) {
//           //Loading State
//           if (state is TransacLoadingState) {
//             return const CustomAllLoader();
//           }
//           //Loaded State
//           else if (state is TransacLoadedState) {
//             TransactionResModel transacData = state.transacRes;

//             //For Storing the transactionDate and dateWiseTransactionData
//             transacData.data?.forEach((key, value) {
//               availableDate?.addAll([key]);
//             });

//             // //Getting how many transactions are done in same day or date
//             // transacData.data?.forEach((dayDate) {
//             //   //Storing all the transaction dateTime in new list
//             //   sameDayDateTransactionList
//             //       ?.add(dateFormatDate.format(dayDate.transactionDate!));
//             // });

//             // //Removing the same dateTime from the list and then assigning the latest value
//             // sameDayDateTransactionList =
//             //     sameDayDateTransactionList?.toSet().toList();

//             // //Now Getting all the data of every transaction according to its dateTime
//             // transacData.data?.forEach((dayDateTra) {
//             //   // dayDateAllTransaction.addAll();
//             //   // dayDateAllTransaction = transacData.data!
//             //   //     .where((element) =>
//             //   //         dateFormatDate.format(element.transactionDate!) ==
//             //   //         dayDateTra)
//             //   //     .toList();
//             // });

//             return SizedBox(
//               width: MediaQuery.of(context).size.width,
//               height: constraints.maxHeight / 1,
//               child: Column(
//                 // mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Universal Piiink
//                   Padding(
//                     padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
//                     child: AutoSizeText(
//                       avaUni,
//                       style: transUni,
//                     ),
//                   ),
//                   AutoSizeText(
//                     '${toFixed2DecimalPlaces(widget.uniBalance)} Piiinks',
//                     style: transUniBal.copyWith(color: GlobalColors.appColor),
//                   ),

//                   const SizedBox(height: 10),

//                   //TopUp and Transfer Icon and View all Icon
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.center,
//                   //   children: [
//                   //     //TopUp
//                   //     TransTabContainer(
//                   //       icon: Icons.add_box_rounded,
//                   //       text: topUpTitle,
//                   //       onPressed: () {
//                   //         Navigator.pushNamed(context, TopUpScreen.routeName);
//                   //       },
//                   //     ),
//                   //     const SizedBox(width: 20),
//                   //     //Transfer
//                   //     TransTabContainer(
//                   //       icon: Icons.send,
//                   //       text: 'Transfer',
//                   //       onPressed: () {
//                   //         Navigator.pushNamed(context, TransferPiiinks.routeName);
//                   //       },
//                   //       angle: 100,
//                   //     ),
//                   //     const SizedBox(width: 20),
//                   //     //View All
//                   //     TransTabContainer(
//                   //       icon: Icons.visibility,
//                   //       text: 'View All',
//                   //       onPressed: () {},
//                   //     ),
//                   //   ],
//                   // ),
//                   // const SizedBox(height: 10),

//                   // Transaction
//                   availableDate!.isEmpty
//                       ? noData()
//                       : Expanded(
//                           child: ScrollConfiguration(
//                             behavior: const ScrollBehavior(),
//                             child: SizedBox(
//                               width: MediaQuery.of(context).size.width,
//                               child: SingleChildScrollView(
//                                 child: ListView.separated(
//                                     physics:
//                                         const NeverScrollableScrollPhysics(),
//                                     shrinkWrap: true,
//                                     padding: const EdgeInsets.only(
//                                         top: 10.0, bottom: 90.0),
//                                     separatorBuilder: (context, index) {
//                                       return const SizedBox(height: 20);
//                                     },
//                                     itemCount: availableDate!.length,
//                                     itemBuilder: (context, index) {
//                                       return Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           // Today, Yesterday and Date
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               //Today, Yesterday
//                                               Flexible(
//                                                 child: Container(
//                                                   margin: const EdgeInsets
//                                                           .symmetric(
//                                                       horizontal: 10.0),
//                                                   padding: const EdgeInsets
//                                                           .symmetric(
//                                                       horizontal: 30.0,
//                                                       vertical: 5.0),
//                                                   decoration:
//                                                       const BoxDecoration(
//                                                     color:
//                                                         GlobalColors.appColor1,
//                                                     borderRadius:
//                                                         BorderRadius.only(
//                                                       topLeft:
//                                                           Radius.circular(20.0),
//                                                       topRight:
//                                                           Radius.circular(20.0),
//                                                     ),
//                                                   ),
//                                                   child: AutoSizeText(
//                                                     dateFormatDate.format(
//                                                         stringToDateTime.parse(
//                                                             availableDate![
//                                                                 index])),
//                                                     style:
//                                                         transConTitl.copyWith(
//                                                             color:
//                                                                 Colors.white),
//                                                   ),
//                                                 ),
//                                               ),

//                                               const SizedBox(width: 10),

//                                               // Date
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     right: 10.0),
//                                                 child: AutoSizeText(
//                                                   stringToDateTime
//                                                           .parse(availableDate![
//                                                               index])
//                                                           .isToday()
//                                                       ? 'Today'
//                                                       : stringToDateTime
//                                                               .parse(
//                                                                   availableDate![
//                                                                       index])
//                                                               .isYesterday()
//                                                           ? 'Yesterday'
//                                                           : dateFormatweek.format(
//                                                               stringToDateTime.parse(
//                                                                   availableDate![
//                                                                       index])),
//                                                   style: transUni,
//                                                   textAlign: TextAlign.end,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),

//                                           //Transaction Container
//                                           Container(
//                                               margin:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 10.0),
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 15.0,
//                                                       vertical: 10.0),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     const BorderRadius.only(
//                                                   topRight:
//                                                       Radius.circular(5.0),
//                                                   bottomLeft:
//                                                       Radius.circular(5.0),
//                                                   bottomRight:
//                                                       Radius.circular(5.0),
//                                                 ),
//                                                 color: GlobalColors
//                                                     .appWhiteBackgroundColor,
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.grey
//                                                         .withValues(alpha: 0.5),
//                                                     blurRadius: 4,
//                                                     spreadRadius: 4,
//                                                     offset: const Offset(2, 2),
//                                                   )
//                                                 ],
//                                               ),
//                                               child: ListView.separated(
//                                                   physics:
//                                                       const NeverScrollableScrollPhysics(),
//                                                   shrinkWrap: true,
//                                                   separatorBuilder:
//                                                       (context, index2) {
//                                                     return const Divider(
//                                                         thickness: 2);
//                                                   },
//                                                   itemCount: transacData
//                                                       .data![availableDate![
//                                                           index]]!
//                                                       .length,
//                                                   itemBuilder:
//                                                       (context, index2) {
//                                                     return Column(
//                                                       children: [
//                                                         // Title and SubTitle and Transaction Done
//                                                         Row(
//                                                           children: [
//                                                             //Title and Sub Title
//                                                             SizedBox(
//                                                               width: MediaQuery.of(
//                                                                           context)
//                                                                       .size
//                                                                       .width /
//                                                                   1.5,
//                                                               child: Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   //Title or Merchant Name and Discount Percentage
//                                                                   AutoSizeText
//                                                                       .rich(
//                                                                     TextSpan(
//                                                                       text: transacData
//                                                                           .data![
//                                                                               availableDate![index]]![
//                                                                               index2]
//                                                                           .merchant!
//                                                                           .merchantName!,
//                                                                       style:
//                                                                           transConTitl,
//                                                                       children: [
//                                                                         //Discount Percentage
//                                                                         TextSpan(
//                                                                           text:
//                                                                               ' (${removeTrailingZero(transacData.data![availableDate![index]]![index2].discountPercentage?.toString() ?? 'No Discount')}%)',
//                                                                           style:
//                                                                               transConSubTitl.copyWith(color: Colors.black),
//                                                                         )
//                                                                       ],
//                                                                     ),
//                                                                   ),

//                                                                   const SizedBox(
//                                                                       height:
//                                                                           3),

//                                                                   //Sub Title or wallet type
//                                                                   AutoSizeText(
//                                                                     transacData.data![availableDate![index]]![index2].piiinkWalletType! ==
//                                                                             'universalWallet'
//                                                                         ? 'Universal Wallet'
//                                                                         : 'Merchant Wallet',
//                                                                     style: transConSubTitl.copyWith(
//                                                                         fontSize:
//                                                                             17.sp),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),

//                                                             //Transaction Amount Piiinks and Currency and Discount Percentage
//                                                             Expanded(
//                                                               child: Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .end,
//                                                                 children: [
//                                                                   //Transaction Amount and Currency
//                                                                   AutoSizeText(
//                                                                     '${toFixed2DecimalPlaces(
//                                                                       transacData
//                                                                           .data![
//                                                                               availableDate![index]]![
//                                                                               index2]
//                                                                           .transactionAmount!,
//                                                                     )}'
//                                                                     ' ${transacData.data![availableDate![index]]![index2].transactionCurrency}',
//                                                                     // textAlign:
//                                                                     //     TextAlign.end,
//                                                                     style:
//                                                                         transacAmtStyle,
//                                                                   ),

//                                                                   const SizedBox(
//                                                                       height:
//                                                                           3),

//                                                                   //Discount Amount
//                                                                   AutoSizeText(
//                                                                     '${toFixed2DecimalPlaces(transacData.data![availableDate![index]]![index2].discountAmount!)} Piiinks',
//                                                                     style:
//                                                                         discountAmtStyle,
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),

//                                                         const SizedBox(
//                                                             height: 5),

//                                                         //Rebate in every transaction
//                                                         Row(
//                                                           children: [
//                                                             // Rebate and Rebate Piiink and Time
//                                                             Expanded(
//                                                               flex: 2,
//                                                               child:
//                                                                   AutoSizeText
//                                                                       .rich(
//                                                                 TextSpan(
//                                                                     text:
//                                                                         'Rebate: ',
//                                                                     style:
//                                                                         transUni,
//                                                                     children: [
//                                                                       TextSpan(
//                                                                         text:
//                                                                             '${toFixed2DecimalPlaces(transacData.data![availableDate![index]]![index2].rebateAmount!)} Merchant Piiinks',
//                                                                         style: transUni
//                                                                             .copyWith(
//                                                                           color:
//                                                                               GlobalColors.appColor,
//                                                                         ),
//                                                                       ),
//                                                                     ]),
//                                                               ),
//                                                             ),

//                                                             const SizedBox(
//                                                                 width: 10),

//                                                             //Transaction Time
//                                                             Expanded(
//                                                               child:
//                                                                   AutoSizeText(
//                                                                 // you have time in utc and it is converted into local
//                                                                 dateFormatTime.format(transacData
//                                                                     .data![
//                                                                         availableDate![
//                                                                             index]]![
//                                                                         index2]
//                                                                     .transactionDate!
//                                                                     .toLocal()),
//                                                                 style: transUni
//                                                                     .copyWith(
//                                                                         color: Colors
//                                                                             .grey),
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .end,
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),

//                                                         const SizedBox(
//                                                             height: 5),
//                                                       ],
//                                                     );
//                                                   }))
//                                         ],
//                                       );
//                                     }),
//                               ),
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             );
//           }
//           // Error State
//           else if (state is TransacErrorState) {
//             return const Error1();
//           } else {
//             return const SizedBox();
//           }
//         },
//       ),
//     );
//   }

//   //If no transaction data is available
//   noData() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
//       child: NotAvailable(
//         titleText: noTransactitle,
//         bodyText: noTransacBody,
//         image: "assets/images/shopping-bag.png",
//       ),
//     );
//   }

//   //Filter Modal
//   filterTransac() {
//     return showModalBottomSheet(
//         context: context,
//         elevation: 0,
//         // constraints: BoxConstraints(
//         //   maxWidth: MediaQuery.of(context).size.width /
//         //       1.1, // here increase or decrease in width
//         // ),
//         builder: (context) {
//           return Container(
//             width: MediaQuery.of(context).size.width / 1.3,
//             // height: MediaQuery.of(context).size.height / 2,
//             decoration: BoxDecoration(
//               color: GlobalColors.appWhiteBackgroundColor,
//               borderRadius: BorderRadius.circular(5.0),
//             ),
//             child: StatefulBuilder(builder: (context, stateMod) {
//               return Column(
//                 children: [
//                   SizedBox(height: 15.h),

//                   // Grey Line
//                   Container(
//                     width: 65.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                         color: Colors.grey.withValues(alpha: 0.5),
//                         borderRadius: BorderRadius.circular(50)),
//                   ),

//                   SizedBox(height: 15.h),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width / 2.3,
//                         child: TextFormField(
//                           controller: latestDateController,
//                           cursorColor: GlobalColors.appColor,
//                           decoration:
//                               textInputDecoration1.copyWith(hintText: 'From'),
//                           readOnly: true,
//                           onTap: () async {
//                             DateTime? pickedDate = await showDatePicker(
//                                 context: context,
//                                 // intialDate indicates the present supported year in a picker
//                                 initialDate: DateTime.now(),

//                                 // firstDate indicates the previous supported year in a picker
//                                 firstDate: DateTime(1950),

//                                 // lastDate indicates the upComing supported year in a picker
//                                 lastDate: DateTime(2100));

//                             if (pickedDate != null) {
//                               // print(
//                               //     pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
//                               String formattedDate =
//                                   DateFormat('yyyy-MM-dd').format(pickedDate);
//                               // print(
//                               //     formattedDate); //formatted date output using intl package =>  2021-03-16
//                               stateMod(() {
//                                 latestDateController.text =
//                                     formattedDate; //set output date to TextField value.
//                               });
//                             } else {
//                               //if user clicks on cancel button
//                               return;
//                             }
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width / 2.3,
//                         child: TextFormField(
//                           controller: previousDateController,
//                           cursorColor: GlobalColors.appColor,
//                           decoration:
//                               textInputDecoration1.copyWith(hintText: 'To'),
//                           readOnly: true,
//                           onTap: () async {
//                             DateTime? pickedDate = await showDatePicker(
//                                 context: context,
//                                 // intialDate indicates the present supported year in a picker
//                                 initialDate: DateTime.now(),

//                                 // firstDate indicates the previous supported year in a picker
//                                 firstDate: DateTime(1950),

//                                 // lastDate indicates the upComing supported year in a picker
//                                 lastDate: DateTime(2100));

//                             if (pickedDate != null) {
//                               // print(
//                               //     pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
//                               String formattedDate =
//                                   DateFormat('yyyy-MM-dd').format(pickedDate);
//                               // print(
//                               //     formattedDate); //formatted date output using intl package =>  2021-03-16
//                               stateMod(() {
//                                 previousDateController.text =
//                                     formattedDate; //set output date to TextField value.
//                               });
//                             } else {
//                               //if user clicks on cancel button
//                               return;
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(
//                     height: 20.h,
//                   ),

//                   //Apply Button
//                   Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(5.0),
//                         boxShadow: [
//                           BoxShadow(
//                               color: Colors.grey.withValues(alpha: 0.2),
//                               spreadRadius: 1,
//                               blurRadius: 4,
//                               offset: const Offset(2, 2))
//                         ]),
//                     width: MediaQuery.of(context).size.width / 1.2,
//                     height: 45,
//                     child: ElevatedButton(
//                       onPressed: () {},
//                       style: styleMainButton,
//                       child: AutoSizeText(
//                         'Apply',
//                         style: buttonText.copyWith(fontSize: 20.sp),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }),
//           );
//         });
//   }
// }
