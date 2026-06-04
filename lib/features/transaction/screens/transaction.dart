import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/widgets/calender_theme.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_button.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/not_available.dart';
import 'package:touristsaver/constants/date_helper.dart';
import 'package:touristsaver/constants/decimal_remove.dart';
import 'package:touristsaver/constants/fixed_decimal.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/number_formatter.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/connectivity/cubit/internet_cubit.dart';
import 'package:touristsaver/features/connectivity/screens/connectivity.dart';
import 'package:touristsaver/features/transaction/services/dio_transaction.dart';
import 'package:touristsaver/models/response/transaction_res.dart';

import '../../connectivity/screens/connectivity_screen.dart';
import 'package:touristsaver/generated/l10n.dart';

class TransactionScreen extends StatefulWidget {
  static const String routeName = '/statement';
  final double uniBalance;
  const TransactionScreen({super.key, required this.uniBalance});
  // const StatementScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final GlobalKey<FormState> dateKey = GlobalKey<FormState>();
  final GlobalKey<RefreshIndicatorState> transRefreshKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController previousDateController = TextEditingController();
  final TextEditingController latestDateController = TextEditingController();
  //for formatting dateTime
  DateFormat dateFormatTime = DateFormat(" HH:mm a"); //Example: 4:30
  DateFormat dateFormatDate = DateFormat("dd-MM-yyyy"); //Example: 1-1-2023
  DateFormat stringToDateTime = DateFormat("yyyy-MM-dd"); //Example: 2023-01-01
  //Creating this variable to only call the API when clicked in apply button
  //For search button Clicked
  String? fromDate;
  String? toDate;
  //For InitState
  String? fromDateInit;
  String? toDateInit;
  //For selected date from calendar
  String? fromDateoo;
  String? toDateoo;
  bool load = false;
// For storing the transactionDate
  List<String>? availableDate = [];
  //Calling API of Transaction
  Future<TransactionResModel>? transacRes;
  Future<TransactionResModel>? getTransacData(
      String fromDatey, String toDatey) async {
    TransactionResModel? transactionResModel =
        await DioTransaction().transac(fromDatey, toDatey);
    //For Storing the transactionDate
    transactionResModel?.data?.forEach((key, value) {
      availableDate?.addAll([key]);
    });
    setState(() {
      load = false;
    });
    return transactionResModel!;
  }

  //For achieving the date before 7 days from the latest day
  DateTime? dateBefore7Days;
  DateTime findLastDateOfPreviousWeek(DateTime dateTime) {
    final DateTime before7DaysDate = dateTime.subtract(const Duration(days: 7));
    return before7DaysDate;
  }

  @override
  void initState() {
    dateBefore7Days = findLastDateOfPreviousWeek(DateTime.now());
    fromDateInit = stringToDateTime.format(dateBefore7Days!);
    toDateInit = stringToDateTime.format(DateTime.now());
    transacRes = getTransacData(fromDateInit!, toDateInit!);
    super.initState();
  }

  @override
  void dispose() {
    ConnectivityCubit().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: transRefreshKey,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
        transacRes = getTransacData(fromDateInit!, toDateInit!);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            text: S.of(context).transactionHistory,
            icon: Icons.arrow_back_ios,
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, state) {
            if (state == ConnectivityState.loading) {
              return const NoInternetLoader();
            } else if (state == ConnectivityState.disconnected) {
              return const NoConnectivityScreen();
            } else if (state == ConnectivityState.connected) {
              return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  child: secondDesign(context, constraints),
                );
              });
            } else {
              return const SizedBox();
            }
          },
        ),

        //Floating action button for filtering
        floatingActionButton: FloatingActionButton.extended(
          label: AutoSizeText(
            S.of(context).filter,
            style: transUni.copyWith(color: Colors.white),
          ),
          backgroundColor: GlobalColors.appColor1,
          onPressed: () {
            latestDateController.clear();
            previousDateController.clear();
            filterTransac();
          },
          icon: const Icon(
            Icons.filter_list_rounded,
            color: GlobalColors.appWhiteBackgroundColor,
            size: 25,
          ),
        ),
      ),
    );
  }

  secondDesign(BuildContext context, BoxConstraints constraints) {
    // // To know how many transactions are available in same day or date
    // List<String>? sameDayDateTransactionList = [];
    // //Storing the transaction data according to its dataTime
    // // Map<String, dynamic>? dayDateAllTransaction = [];
    // List<Datum>? dayDateAllTransaction = [];
    return load == true
        ? const CustomAllLoader()
        : FutureBuilder<TransactionResModel?>(
            future: transacRes,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Error1();
              } else if (!snapshot.hasData) {
                return const CustomAllLoader();
              } else {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: constraints.maxHeight / 1,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Universal Piiink
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                        child: AutoSizeText(
                          S.of(context).availableUniversalTouristSavers,
                          style: transUni,
                        ),
                      ),
                      AutoSizeText(
                        '${numFormatter.format(widget.uniBalance)} ${S.of(context).touristSavers}',
                        style:
                            transUniBal.copyWith(color: GlobalColors.appColor),
                      ),

                      const SizedBox(height: 10),

                      snapshot.data!.data!.isEmpty
                          ? noData()
                          : Expanded(
                              child: ScrollConfiguration(
                                behavior: const ScrollBehavior(),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    child: ListView.separated(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 90.0),
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(height: 20);
                                        },
                                        itemCount: availableDate!.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Today, Yesterday and Date
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Date
                                                  Flexible(
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10.0),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 30.0,
                                                          vertical: 5.0),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: GlobalColors
                                                            .appColor1,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  20.0),
                                                        ),
                                                      ),
                                                      child: AutoSizeText(
                                                        dateFormatDate.format(
                                                            stringToDateTime.parse(
                                                                availableDate![
                                                                    index])),
                                                        style: transConTitl
                                                            .copyWith(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(width: 10),
                                                  //Today, Yesterday
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: AutoSizeText(
                                                      stringToDateTime
                                                              .parse(
                                                                  availableDate![
                                                                      index])
                                                              .isToday()
                                                          ? S.of(context).today
                                                          //'Today'
                                                          : stringToDateTime
                                                                  .parse(
                                                                      availableDate![
                                                                          index])
                                                                  .isYesterday()
                                                              ? S
                                                                  .of(context)
                                                                  .yesterday
                                                              //'Yesterday'

                                                              : timeAgoCustom(stringToDateTime.parse(
                                                                          availableDate![
                                                                              index])) ==
                                                                      "Sunday"
                                                                  ? S
                                                                      .of(
                                                                          context)
                                                                      .sunday
                                                                  : timeAgoCustom(stringToDateTime.parse(availableDate![
                                                                              index])) ==
                                                                          "Monday"
                                                                      ? S
                                                                          .of(
                                                                              context)
                                                                          .monday
                                                                      : timeAgoCustom(stringToDateTime.parse(availableDate![index])) ==
                                                                              "Tuesday"
                                                                          ? S
                                                                              .of(context)
                                                                              .tuesday
                                                                          : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Wednesday"
                                                                              ? S.of(context).wednesday
                                                                              : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Thursday"
                                                                                  ? S.of(context).thursday
                                                                                  : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Friday"
                                                                                      ? S.of(context).friday
                                                                                      : S.of(context).saturday,
                                                      style: transUni,
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              //Transaction Container
                                              Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15.0,
                                                      vertical: 10.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(5.0),
                                                      bottomLeft:
                                                          Radius.circular(5.0),
                                                      bottomRight:
                                                          Radius.circular(5.0),
                                                    ),
                                                    color: GlobalColors
                                                        .appWhiteBackgroundColor,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.5),
                                                        blurRadius: 4,
                                                        spreadRadius: 4,
                                                        offset:
                                                            const Offset(2, 2),
                                                      )
                                                    ],
                                                  ),
                                                  child: ListView.separated(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      separatorBuilder:
                                                          (context, index2) {
                                                        return const Divider(
                                                            thickness: 2);
                                                      },
                                                      itemCount: snapshot
                                                          .data!
                                                          .data![availableDate![
                                                              index]]!
                                                          .length,
                                                      itemBuilder:
                                                          (context, index2) {
                                                        return Column(
                                                          children: [
                                                            // Title and SubTitle and Transaction Done
                                                            Row(
                                                              children: [
                                                                //Title and Sub Title
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      1.7,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      //Title or Merchant Name and Discount Percentage
                                                                      AutoSizeText
                                                                          .rich(
                                                                        TextSpan(
                                                                          text: snapshot
                                                                              .data!
                                                                              .data![availableDate![index]]![index2]
                                                                              .merchant!
                                                                              .merchantName!,
                                                                          style:
                                                                              transConTitl,
                                                                          children: [
                                                                            //Discount Percentage
                                                                            TextSpan(
                                                                              text: ' (${removeTrailingZero(snapshot.data!.data![availableDate![index]]![index2].discountPercentage?.toString() ?? S.of(context).noDiscount)}%)',
                                                                              style: transConSubTitl.copyWith(color: Colors.black),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),

                                                                      const SizedBox(
                                                                          height:
                                                                              3),

                                                                      //Sub Title or wallet type
                                                                      AutoSizeText(
                                                                        snapshot.data!.data![availableDate![index]]![index2].piiinkWalletType! ==
                                                                                'universalWallet'
                                                                            ? S.of(context).universalWallet
                                                                            // 'Universal Wallet'
                                                                            : S.of(context).merchantWallet,
                                                                        //'Merchant Wallet',
                                                                        style: transConSubTitl.copyWith(
                                                                            fontSize:
                                                                                17.sp),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                                //Transaction Amount Piiinks and Currency and Discount Percentage
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      //Transaction Amount and Currency
                                                                      AutoSizeText(
                                                                        '${toFixed2DecimalPlaces(
                                                                          snapshot
                                                                              .data!
                                                                              .data![availableDate![index]]![index2]
                                                                              .transactionAmount!,
                                                                        )}'
                                                                        ' ${snapshot.data!.data![availableDate![index]]![index2].transactionCurrency}',
                                                                        style:
                                                                            transacAmtStyle,
                                                                      ),

                                                                      const SizedBox(
                                                                          height:
                                                                              3),
                                                                      //Discount Amount
                                                                      AutoSizeText(
                                                                        '${toFixed2DecimalPlaces(snapshot.data!.data![availableDate![index]]![index2].discountAmount!)} ${S.of(context).touristSavers}',
                                                                        style:
                                                                            discountAmtStyle,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            //Rebate in every transaction
                                                            Row(
                                                              children: [
                                                                // Rebate and Rebate Piiink and Time
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      AutoSizeText
                                                                          .rich(
                                                                    TextSpan(
                                                                        text:
                                                                            '${S.of(context).rebate} : ',
                                                                        //  'Rebate: ',
                                                                        style:
                                                                            transUni,
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                '${toFixed2DecimalPlaces(snapshot.data!.data![availableDate![index]]![index2].rebateAmount!)} ${S.of(context).merchantWallet}',
                                                                            style:
                                                                                transUni.copyWith(
                                                                              color: GlobalColors.appColor,
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                //Transaction Time
                                                                Expanded(
                                                                  child:
                                                                      AutoSizeText(
                                                                    // you have time in utc and it is converted into local
                                                                    dateFormatTime.format(snapshot
                                                                        .data!
                                                                        .data![
                                                                            availableDate![index]]![
                                                                            index2]
                                                                        .transactionDate!
                                                                        .toLocal()),
                                                                    style: transUni
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.grey),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            //Transaction Id of every transaction
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      AutoSizeText
                                                                          .rich(
                                                                    TextSpan(
                                                                        text:
                                                                            '${S.of(context).transactionId} : ',
                                                                        // 'Transaction ID : ',
                                                                        style:
                                                                            transUni,
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                snapshot.data!.data![availableDate![index]]![index2].transactionId,
                                                                            style:
                                                                                transUni.copyWith(
                                                                              color: GlobalColors.appColor,
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                          ],
                                                        );
                                                      }))
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              }
            });
  }

  //If no transaction data is available
  noData() {
    String replacement =
        fromDate ?? dateFormatDate.format(DateTime.parse(fromDateInit!));
    String replacement2 =
        toDate ?? dateFormatDate.format(DateTime.parse(toDateInit!));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: NotAvailable(
        titleText: S.of(context).noTransactionHasBeenCompletedYet,
        bodyText: S
            .of(context)
            .youDoNotHaveAnyTransactionHistoryToViewBetweenXTOY
            .replaceAll('&X', replacement)
            .replaceAll('&Y', replacement2),
        // titleText: noTransactitle,
        // bodyText:
        //     '$noTransacBody between ${fromDate == null ? dateFormatDate.format(DateTime.parse(previousDateController.text)) : previousDateController.text} to ${toDate == null ? dateFormatDate.format(DateTime.parse(latestDateController.text)) : latestDateController.text}',
        image: "assets/images/shopping-bag.png",
      ),
    );
  }

  bool decideWhichDayToEnable(DateTime getDate) {
    if ((getDate.isAfter(dateFormatDate
                .parse(previousDateController.text)
                .subtract(const Duration(days: 1))) &&
            getDate.isBefore(DateTime.now())
        // .isBefore(dateFormatDate
        //     .parse(previousDateController.text)
        //     .add(const Duration(days: 30)))
        )) {
      return true;
    }
    return false;
  }

  // bool decideWhichDayToEnable(DateTime getDate) {
  //   if ((getDate.isAfter(dateFormatDate
  //           .parse(previousDateController.text)
  //           .subtract(const Duration(days: 1))) &&
  //       getDate.isBefore(dateFormatDate
  //           .parse(previousDateController.text)
  //           .add(const Duration(days: 30))))) {
  //     return true;
  //   }
  //   return false;
  // }

  //Filter Modal
  filterTransac() {
    return showModalBottomSheet(
        context: context,
        elevation: 0,
        builder: (context) {
          return Container(
            // width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              color: GlobalColors.appWhiteBackgroundColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: StatefulBuilder(builder: (context, stateMod) {
              return Form(
                key: dateKey,
                child: Column(
                  children: [
                    SizedBox(height: 15.h),
                    // Grey Line
                    Container(
                      width: 65.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    SizedBox(height: 15.h),
                    // From and To Date Picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //From
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.3,
                          child: TextFormField(
                            controller: previousDateController,
                            cursorColor: GlobalColors.appColor,
                            decoration: textInputDecoration1.copyWith(
                                hintText: S.of(context).from),
                            validator: (previousDate) {
                              if (previousDate == null ||
                                  previousDate.isEmpty) {
                                return S.of(context).chooseDate;
                              }
                              return null;
                            },
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                // intialDate indicates the present supported year in a picker
                                initialDate: DateTime.now(),
                                // firstDate indicates the previous supported year in a picker
                                firstDate: DateTime(1950),
                                // firstDate: DateTime.now()
                                //     .subtract(const Duration(days: 30)),
                                // lastDate indicates the upComing supported year in a picker
                                lastDate: DateTime.now(),
                                //Changing help text
                                helpText: S.of(context).selectDateFrom,
                                builder: (context, child) {
                                  return calenderTheme(child);
                                },
                              );
                              if (pickedDate != null) {
                                String formattedDate =
                                    dateFormatDate.format(pickedDate);
                                // DateFormat("dd-MM-yyyy").format(pickedDate);
                                fromDateoo =
                                    stringToDateTime.format(pickedDate);
                                setState(() {
                                  previousDateController.text =
                                      formattedDate; //set output date to TextField value.
                                });
                                if (latestDateController.text.isNotEmpty) {
                                  DateTime tfromDate = stringToDateTime
                                      .parse(previousDateController.text);
                                  DateTime ttoDate = stringToDateTime
                                      .parse(latestDateController.text);
                                  if (tfromDate.isAfter(ttoDate)) {
                                    setState(() {
                                      latestDateController.clear();
                                    });
                                  }
                                }
                              } else {
                                //if user clicks on cancel button
                                return;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        //To
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.3,
                          child: TextFormField(
                            controller: latestDateController,
                            cursorColor: GlobalColors.appColor,
                            decoration: textInputDecoration1.copyWith(
                                hintText: S.of(context).to),
                            validator: (latestDate) {
                              if (latestDate == null || latestDate.isEmpty) {
                                return S.of(context).chooseDate;
                              }
                              return null;
                            },
                            // readOnly: true,
                            // enabled: previousDateController.text.isEmpty
                            //     ? false
                            //     : true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                // intialDate indicates the present supported year in a picker
                                // initialDate: DateTime.now(),
                                initialDate: dateFormatDate
                                    .parse(previousDateController.text),
                                // firstDate indicates the previous supported year in a picker
                                firstDate: DateTime(1950),
                                // lastDate indicates the upComing supported year in a picker
                                lastDate: DateTime(2100),
                                //Changing help text
                                helpText: S.of(context).selectDateTo,
                                selectableDayPredicate: decideWhichDayToEnable,
                                builder: (context, child) {
                                  return calenderTheme(child);
                                },
                              );
                              if (pickedDate != null) {
                                String formattedDate =
                                    dateFormatDate.format(pickedDate);
                                // DateFormat("dd-MM-yyyy").format(pickedDate);
                                toDateoo = stringToDateTime.format(pickedDate);
                                setState(() {
                                  latestDateController.text =
                                      formattedDate; //set output date to TextField value.
                                });
                              } else {
                                //if user clicks on cancel button
                                return;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    //Apply Button
                    ModalCustomButton(
                      text: S.of(context).apply,
                      onPressed: () async {
                        if (dateKey.currentState!.validate()) {
                          setState(() {
                            load = true;
                            fromDate = previousDateController.text.isEmpty
                                ? dateFormatDate
                                    .format(DateTime.parse(fromDate!))
                                : previousDateController.text;
                            toDate = latestDateController.text.isEmpty
                                ? dateFormatDate.format(DateTime.parse(toDate!))
                                : latestDateController.text;
                            // fromDate = fromDateoo;
                            // toDate = toDateoo;
                            transacRes = getTransacData(fromDateoo!, toDateoo!);
                          });
                          //Clearing the previous data to add new data and remove the duplicate
                          availableDate?.clear();
                          context.pop();
                        }
                      },
                    ),
                    SizedBox(height: 15.h),
                    // Cancel Button
                    ModalCustomButton1(
                      text: S.of(context).cancel,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }
}
