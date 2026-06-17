import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/features/top_up/widgets/premium_topup_history_widget.dart';
import 'package:touristsaver/features/top_up/widgets/top_up_history_widget.dart';

const Color _historyPrimaryBlue = Color(0xFF0009FE);
const Color _historyNavy = Color(0xFF111C44);
const Color _historyMuted = Color(0xFF61708A);
const Color _historyBackground = Color(0xFFF8FAFE);

class TopUpHistoryScreen extends StatefulWidget {
  static const String routeName = '/top_up_history';
  // final double uniBalance;
  const TopUpHistoryScreen({super.key});

  @override
  State<TopUpHistoryScreen> createState() => _TopUpHistoryScreenState();
}

class _TopUpHistoryScreenState extends State<TopUpHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: _historyBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight * 1.6),
            child: CustomAppBar(
              text: 'Premium Savings Activity',
              icon: Icons.arrow_back_ios,
              textColor: _historyNavy,
              fontSize: 17,
              leadingWidth: 40,
              titleSpacing: 0,
              reserveEmptyActions: false,
              onPressed: () {
                context.pop();
              },
              tabs: TabBar(
                  automaticIndicatorColorAdjustment: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                  isScrollable: true,
                  indicatorColor: _historyPrimaryBlue,
                  labelColor: _historyPrimaryBlue,
                  unselectedLabelColor: _historyMuted,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Sans',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Sans',
                  ),
                  tabs: [
                    const Tab(text: 'Membership Value'),
                    const Tab(text: 'Promo Codes Used'),
                  ]),
            ),
          ),
          body: const TabBarView(
            children: [TopUpHistoryWidget(), PremiumTopUpHistory()],
          )),
    );
  }

  // final GlobalKey<FormState> dateKey = GlobalKey<FormState>();
//   final GlobalKey<RefreshIndicatorState> refreshKey =
//       GlobalKey<RefreshIndicatorState>();
//   final TextEditingController previousDateController = TextEditingController();
//   final TextEditingController latestDateController = TextEditingController();
//   //Creating this variable to only call the API when clicked in apply button
//   String? fromDate;
//   String? toDate;
//   bool load = false;
// // For storing the transactionDate
//   List<String>? availableDate = [];

  // //for formatting dateTime
  // DateFormat dateFormatTime = DateFormat(" HH:mm a"); //Example: 4:30
  // DateFormat dateFormatDate = DateFormat("dd-MM-yyyy"); //Example: 1-1-2023
  // DateFormat stringToDateTime = DateFormat("yyyy-MM-dd"); //Example: 2023-01-01

  // //Calling API of Transaction
  // Future<TopUpHistoryResModel>? topUpRes;
  // Future<TopUpHistoryResModel>? getTopUpData() async {
  //   TopUpHistoryResModel? topUpHistoryResModel = await DioTopUpStripe()
  //       .topUpHist(latestDateController.text.trim(),
  //           previousDateController.text.trim());

  //   //For Storing the transactionDate
  //   topUpHistoryResModel?.data?.forEach((key, value) {
  //     availableDate?.addAll([key]);
  //   });

  //   setState(() {
  //     load = false;
  //   });
  //   return topUpHistoryResModel!;
  // }

  //For achieving the date before 7 days from the latest day
  // DateTime? dateBefore7Days;
  // DateTime findLastDateOfPreviousWeek(DateTime dateTime) {
  //   final DateTime before7DaysDate = dateTime.subtract(const Duration(days: 7));
  //   return before7DaysDate;
  // }

  // @override
  // void initState() {
  //   dateBefore7Days = findLastDateOfPreviousWeek(DateTime.now());
  //   previousDateController.text = stringToDateTime.format(dateBefore7Days!);
  //   latestDateController.text = stringToDateTime.format(DateTime.now());
  //   topUpRes = getTopUpData();
  //   super.initState();
  // }

  // secondDesign(BuildContext context, BoxConstraints constraints) {
  //   return load == true
  //       ? const CustomAllLoader()
  //       : FutureBuilder<TopUpHistoryResModel?>(
  //           future: topUpRes,
  //           builder: (context, snapshot) {
  //             if (snapshot.hasError) {
  //               return const Error1();
  //             } else if (!snapshot.hasData) {
  //               return const CustomAllLoader();
  //             } else {
  //               return SizedBox(
  //                 width: MediaQuery.of(context).size.width,
  //                 height: constraints.maxHeight / 1,
  //                 child: Column(
  //                   children: [
  //                     Container(
  //                       height: 50,
  //                       decoration:
  //                           const BoxDecoration(color: GlobalColors.paleGray),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Expanded(
  //                             child: TextButton(
  //                               onPressed: () {},
  //                               child: Text(
  //                                 "Top-up History",
  //                                 // maxLines: 2,
  //                                 overflow: TextOverflow.ellipsis,
  //                                 style: profileListStyle.copyWith(
  //                                     color: GlobalColors.gray),
  //                               ),
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: TextButton(
  //                               onPressed: () {
  //                                 context.pushReplacementNamed(
  //                                     'premium_top_up_history');
  //                               },
  //                               child: Text("Premium Code History",
  //                                   // maxLines: 2,
  //                                   overflow: TextOverflow.ellipsis,
  //                                   style: profileListStyle.copyWith(
  //                                       color: GlobalColors.appColor1)),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     snapshot.data!.data!.isEmpty
  //                         ? noData()
  //                         : Expanded(
  //                             child: ScrollConfiguration(
  //                               behavior: const ScrollBehavior(),
  //                               child: SizedBox(
  //                                 width: MediaQuery.of(context).size.width,
  //                                 child: SingleChildScrollView(
  //                                   child: ListView.separated(
  //                                       physics:
  //                                           const NeverScrollableScrollPhysics(),
  //                                       shrinkWrap: true,
  //                                       padding: const EdgeInsets.only(
  //                                           top: 5.0, bottom: 90.0),
  //                                       separatorBuilder: (context, index) {
  //                                         return const SizedBox(height: 20);
  //                                       },
  //                                       itemCount: availableDate!.length,
  //                                       itemBuilder: (context, index) {
  //                                         return Column(
  //                                           crossAxisAlignment:
  //                                               CrossAxisAlignment.start,
  //                                           children: [
  //                                             const SizedBox(
  //                                               height: 20,
  //                                             ),
  //                                             // Today, Yesterday and Date
  //                                             Row(
  //                                               mainAxisAlignment:
  //                                                   MainAxisAlignment
  //                                                       .spaceBetween,
  //                                               children: [
  //                                                 // Date
  //                                                 Flexible(
  //                                                   child: Container(
  //                                                     margin: const EdgeInsets
  //                                                             .symmetric(
  //                                                         horizontal: 10.0),
  //                                                     padding: const EdgeInsets
  //                                                             .symmetric(
  //                                                         horizontal: 30.0,
  //                                                         vertical: 5.0),
  //                                                     decoration:
  //                                                         const BoxDecoration(
  //                                                       color: GlobalColors
  //                                                           .appColor1,
  //                                                       borderRadius:
  //                                                           BorderRadius.only(
  //                                                         topLeft:
  //                                                             Radius.circular(
  //                                                                 20.0),
  //                                                         topRight:
  //                                                             Radius.circular(
  //                                                                 20.0),
  //                                                       ),
  //                                                     ),
  //                                                     child: AutoSizeText(
  //                                                       dateFormatDate.format(
  //                                                           stringToDateTime.parse(
  //                                                               availableDate![
  //                                                                   index])),
  //                                                       style: transConTitl
  //                                                           .copyWith(
  //                                                               color: Colors
  //                                                                   .white),
  //                                                     ),
  //                                                   ),
  //                                                 ),

  //                                                 const SizedBox(width: 10),
  //                                                 //Today, Yesterday
  //                                                 Padding(
  //                                                   padding:
  //                                                       const EdgeInsets.only(
  //                                                           right: 10.0),
  //                                                   child: AutoSizeText(
  //                                                     stringToDateTime
  //                                                             .parse(
  //                                                                 availableDate![
  //                                                                     index])
  //                                                             .isToday()
  //                                                         ? S.of(context).today
  //                                                         : stringToDateTime
  //                                                                 .parse(
  //                                                                     availableDate![
  //                                                                         index])
  //                                                                 .isYesterday()
  //                                                             ? S
  //                                                                 .of(context)
  //                                                                 .yesterday
  //                                                             : timeAgoCustom(stringToDateTime.parse(
  //                                                                         availableDate![
  //                                                                             index])) ==
  //                                                                     "Sunday"
  //                                                                 ? S
  //                                                                     .of(
  //                                                                         context)
  //                                                                     .sunday
  //                                                                 : timeAgoCustom(stringToDateTime.parse(availableDate![
  //                                                                             index])) ==
  //                                                                         "Monday"
  //                                                                     ? S
  //                                                                         .of(
  //                                                                             context)
  //                                                                         .monday
  //                                                                     : timeAgoCustom(stringToDateTime.parse(availableDate![index])) ==
  //                                                                             "Tuesday"
  //                                                                         ? S
  //                                                                             .of(context)
  //                                                                             .tuesday
  //                                                                         : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Wednesday"
  //                                                                             ? S.of(context).wednesday
  //                                                                             : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Thursday"
  //                                                                                 ? S.of(context).thursday
  //                                                                                 : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Friday"
  //                                                                                     ? S.of(context).friday
  //                                                                                     : S.of(context).saturday,
  //                                                     style: transUni,
  //                                                     textAlign: TextAlign.end,
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),

  //                                             //Transaction Container
  //                                             Container(
  //                                                 margin: const EdgeInsets
  //                                                         .symmetric(
  //                                                     horizontal: 10.0),
  //                                                 padding: const EdgeInsets
  //                                                         .symmetric(
  //                                                     horizontal: 15.0,
  //                                                     vertical: 10.0),
  //                                                 decoration: BoxDecoration(
  //                                                   borderRadius:
  //                                                       const BorderRadius.only(
  //                                                     topRight:
  //                                                         Radius.circular(5.0),
  //                                                     bottomLeft:
  //                                                         Radius.circular(5.0),
  //                                                     bottomRight:
  //                                                         Radius.circular(5.0),
  //                                                   ),
  //                                                   color: GlobalColors
  //                                                       .appWhiteBackgroundColor,
  //                                                   boxShadow: [
  //                                                     BoxShadow(
  //                                                       color: Colors.grey
  //                                                           .withValues(alpha: 0.5),
  //                                                       blurRadius: 4,
  //                                                       spreadRadius: 4,
  //                                                       offset:
  //                                                           const Offset(2, 2),
  //                                                     )
  //                                                   ],
  //                                                 ),
  //                                                 child: ListView.separated(
  //                                                     physics:
  //                                                         const NeverScrollableScrollPhysics(),
  //                                                     shrinkWrap: true,
  //                                                     separatorBuilder:
  //                                                         (context, index2) {
  //                                                       return const Divider(
  //                                                           thickness: 2);
  //                                                     },
  //                                                     itemCount: snapshot
  //                                                         .data!
  //                                                         .data![availableDate![
  //                                                             index]]!
  //                                                         .length,
  //                                                     itemBuilder:
  //                                                         (context, index2) {
  //                                                       var transactionData =
  //                                                           snapshot.data!
  //                                                                       .data![
  //                                                                   availableDate![
  //                                                                       index]]![
  //                                                               index2];
  //                                                       return Column(
  //                                                         children: [
  //                                                           // Title and SubTitle and Transaction Done
  //                                                           Row(
  //                                                             children: [
  //                                                               //Title and Sub Title
  //                                                               SizedBox(
  //                                                                 width: MediaQuery.of(
  //                                                                             context)
  //                                                                         .size
  //                                                                         .width /
  //                                                                     1.7,
  //                                                                 child: Column(
  //                                                                   crossAxisAlignment:
  //                                                                       CrossAxisAlignment
  //                                                                           .start,
  //                                                                   children: [
  //                                                                     //Title or Merchant Name and Discount Percentage

  //                                                                     Text(
  //                                                                       S
  //                                                                           .of(context)
  //                                                                           .topUpAmount,
  //                                                                       style:
  //                                                                           transConTitl,
  //                                                                     ),
  //                                                                   ],
  //                                                                 ),
  //                                                               ),

  //                                                               //Transaction Amount Piiinks and Currency
  //                                                               Expanded(
  //                                                                 child: Column(
  //                                                                   crossAxisAlignment:
  //                                                                       CrossAxisAlignment
  //                                                                           .end,
  //                                                                   children: [
  //                                                                     //Topup Amount and Currency
  //                                                                     AutoSizeText(
  //                                                                       '${transactionData.foreignTransactionCurrency == null ? toFixed2DecimalPlaces(transactionData.totalAmount!) : toFixed2DecimalPlaces(transactionData.foreignTotalAmount!)}'
  //                                                                       ' ${transactionData.foreignTransactionCurrency ?? transactionData.transactionCurrency}',
  //                                                                       // textAlign:
  //                                                                       //     TextAlign.end,
  //                                                                       style:
  //                                                                           transacAmtStyle,
  //                                                                     ),
  //                                                                   ],
  //                                                                 ),
  //                                                               ),
  //                                                             ],
  //                                                           ),
  //                                                           const SizedBox(
  //                                                             height: 10,
  //                                                           ),
  //                                                           //TopUpDate
  //                                                           Row(
  //                                                             children: [
  //                                                               Expanded(
  //                                                                 child:
  //                                                                     AutoSizeText(
  //                                                                   // you have time in utc and it is converted into local
  //                                                                   dateFormatTime.format(snapshot
  //                                                                       .data!
  //                                                                       .data![
  //                                                                           availableDate![index]]![
  //                                                                           index2]
  //                                                                       .transactionDate!
  //                                                                       .toLocal()),
  //                                                                   style: transUni
  //                                                                       .copyWith(
  //                                                                           color:
  //                                                                               Colors.grey),
  //                                                                   textAlign:
  //                                                                       TextAlign
  //                                                                           .end,
  //                                                                 ),
  //                                                               ),
  //                                                             ],
  //                                                           ),

  //                                                           // const SizedBox(
  //                                                           //     height: 5),
  //                                                         ],
  //                                                       );
  //                                                     }))
  //                                           ],
  //                                         );
  //                                       }),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                   ],
  //                 ),
  //               );
  //             }
  //           });
  // }
  // //If no transaction data is available
  // noData() {
  //   String replacement =
  //       dateFormatDate.format(DateTime.parse(previousDateController.text));
  //   String replacement2 =
  //       dateFormatDate.format(DateTime.parse(latestDateController.text));
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
  //     child: NotAvailable(
  //       titleText: S.of(context).noTopUpHasBeenDoneYet,
  //       bodyText: S
  //           .of(context)
  //           .youDoNotHaveAnyTopUpHistoryToViewBetweenXTOY
  //           .replaceAll('@X', replacement)
  //           .replaceAll('@Y', replacement2),
  //       // titleText: 'No Top Up has been done yet!',
  //       // bodyText:
  //       //     'You do not have any top up history to view between ${dateFormatDate.format(DateTime.parse(previousDateController.text))} to ${dateFormatDate.format(DateTime.parse(latestDateController.text))}',
  //       image: "assets/images/shopping-bag.png",
  //     ),
  //   );
  // }
}
