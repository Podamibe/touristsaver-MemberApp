import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/constants/decimal_remove.dart';
import 'package:touristsaver/constants/number_formatter.dart';
import 'package:touristsaver/constants/style.dart';

import '../../../constants/date_helper.dart';
import '../../../models/response/premium_code_top_up_history.dart';
import 'package:touristsaver/generated/l10n.dart';

import '../services/premium_top_up_repository.dart';

const Color _promoPrimaryBlue = Color(0xFF0009FE);
const Color _promoCtaCyan = Color(0xFF18C6FF);
const Color _promoNavy = Color(0xFF111C44);
const Color _promoMuted = Color(0xFF61708A);
const Color _promoBorder = Color(0xFFE2E8F3);

class PremiumTopUpHistory extends StatefulWidget {
  static const String routeName = '/premium_top_up_history';
  // final double uniBalance;
  const PremiumTopUpHistory({super.key});
  // const StatementScreen({super.key});

  @override
  State<PremiumTopUpHistory> createState() => _PremiumTopUpHistoryState();
}

class _PremiumTopUpHistoryState extends State<PremiumTopUpHistory> {
  final GlobalKey<FormState> dateKey = GlobalKey<FormState>();
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController previousDateController = TextEditingController();
  final TextEditingController latestDateController = TextEditingController();
  //Creating this variable to only call the API when clicked in apply button
  String? fromDate;
  String? toDate;
  bool load = false;

  //for formatting dateTime
  DateFormat dateFormatTime = DateFormat(" HH:mm a"); //Example: 4:30
  DateFormat dateFormatDate = DateFormat("dd-MM-yyyy"); //Example: 1-1-2023
  DateFormat stringToDateTime = DateFormat("yyyy-MM-dd"); //Example: 2023-01-01

// For storing the transactionDate
  List<String>? availableDate = [];

  //Calling API of Transaction
  Future<PremiumCodeTopUpHistory>? premiumTopUpRes;
  Future<PremiumCodeTopUpHistory>? getPremiumTopUpData() async {
    PremiumCodeTopUpHistory? premiumCodeTopUpHistory =
        await PremiumTopUpRepository().fetchPremiumCodeTopUpHistory(
            latestDateController.text.trim(),
            previousDateController.text.trim());
    //For Storing the transactionDate
    premiumCodeTopUpHistory?.data?.forEach((key, value) {
      availableDate?.addAll([key]);
    });

    setState(() {
      load = false;
    });
    return premiumCodeTopUpHistory!;
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
    previousDateController.text = stringToDateTime.format(dateBefore7Days!);
    latestDateController.text = stringToDateTime.format(DateTime.now());
    premiumTopUpRes = getPremiumTopUpData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
        child: secondDesign(context, constraints),
      );
    });
  }

  secondDesign(BuildContext context, BoxConstraints constraints) {
    return load == true
        ? const CustomAllLoader()
        : FutureBuilder<PremiumCodeTopUpHistory?>(
            future: premiumTopUpRes,
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
                    children: [
                      snapshot.data!.data!.isEmpty
                          ? noData()
                          : Expanded(
                              child: ScrollConfiguration(
                                behavior: const ScrollBehavior(),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              14, 12, 14, 0),
                                          child: AutoSizeText(
                                            'Promo or voucher codes used for Premium Membership value.',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: _promoMuted,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Sans',
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                        ListView.separated(
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
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  // Today, Yesterday and Date
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // Date
                                                      Flexible(
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10.0),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      30.0,
                                                                  vertical:
                                                                      5.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                const LinearGradient(
                                                              colors: [
                                                                _promoPrimaryBlue,
                                                                _promoCtaCyan,
                                                              ],
                                                              begin: Alignment
                                                                  .centerLeft,
                                                              end: Alignment
                                                                  .centerRight,
                                                            ),
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      20.0),
                                                              topRight: Radius
                                                                  .circular(
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
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10.0),
                                                        child: AutoSizeText(
                                                          stringToDateTime
                                                                  .parse(
                                                                      availableDate![
                                                                          index])
                                                                  .isToday()
                                                              ? S
                                                                  .of(context)
                                                                  .today
                                                              : stringToDateTime
                                                                      .parse(availableDate![
                                                                          index])
                                                                      .isYesterday()
                                                                  ? S
                                                                      .of(
                                                                          context)
                                                                      .yesterday
                                                                  : timeAgoCustom(stringToDateTime.parse(availableDate![
                                                                              index])) ==
                                                                          "Sunday"
                                                                      ? S
                                                                          .of(
                                                                              context)
                                                                          .sunday
                                                                      : timeAgoCustom(stringToDateTime.parse(availableDate![index])) ==
                                                                              "Monday"
                                                                          ? S
                                                                              .of(context)
                                                                              .monday
                                                                          : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Tuesday"
                                                                              ? S.of(context).tuesday
                                                                              : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Wednesday"
                                                                                  ? S.of(context).wednesday
                                                                                  : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Thursday"
                                                                                      ? S.of(context).thursday
                                                                                      : timeAgoCustom(stringToDateTime.parse(availableDate![index])) == "Friday"
                                                                                          ? S.of(context).friday
                                                                                          : S.of(context).saturday,
                                                          style: transUni,
                                                          textAlign:
                                                              TextAlign.end,
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
                                                            const BorderRadius
                                                                .only(
                                                          topRight:
                                                              Radius.circular(
                                                                  5.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  5.0),
                                                        ),
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                _promoBorder),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha:
                                                                        0.06),
                                                            blurRadius: 18,
                                                            offset:
                                                                const Offset(
                                                                    0, 8),
                                                          )
                                                        ],
                                                      ),
                                                      child: ListView.separated(
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          separatorBuilder:
                                                              (context,
                                                                  index2) {
                                                            return const Divider(
                                                                thickness: 2);
                                                          },
                                                          itemCount: snapshot
                                                              .data!
                                                              .data![
                                                                  availableDate![
                                                                      index]]!
                                                              .length,
                                                          itemBuilder: (context,
                                                              index2) {
                                                            var transactionData =
                                                                snapshot.data!
                                                                        .data![
                                                                    availableDate![
                                                                        index]]![index2];
                                                            return Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    AutoSizeText(
                                                                      "Promo code: ",
                                                                      style: transUni.copyWith(
                                                                          color:
                                                                              _promoMuted),
                                                                    ),
                                                                    AutoSizeText(
                                                                      transactionData
                                                                          .memberPremiumCode
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: transUni.copyWith(
                                                                          color:
                                                                              _promoPrimaryBlue),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    AutoSizeText(
                                                                      "${S.of(context).receivedTouristSavers}: ",
                                                                      style: transUni.copyWith(
                                                                          color:
                                                                              _promoMuted),
                                                                    ),
                                                                    AutoSizeText(
                                                                      "${removeTrailingZero(numFormatter.format(transactionData.piiinksProvided))} ${S.of(context).touristSavers}",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: transUni.copyWith(
                                                                          color:
                                                                              _promoPrimaryBlue),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    AutoSizeText(
                                                                      "${S.of(context).package}: ",
                                                                      style: transUni.copyWith(
                                                                          color:
                                                                              _promoMuted),
                                                                    ),
                                                                    AutoSizeText(
                                                                      "${transactionData.membershipPackage?.packageName}",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: transUni.copyWith(
                                                                          color:
                                                                              _promoPrimaryBlue),
                                                                    ),
                                                                  ],
                                                                ),
                                                                //TopUpDate
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          AutoSizeText(
                                                                        // you have time in utc and it is converted into local
                                                                        dateFormatTime.format(snapshot
                                                                            .data!
                                                                            .data![availableDate![index]]![index2]
                                                                            .appliedDate!
                                                                            .toLocal()),
                                                                        style: transUni.copyWith(
                                                                            color:
                                                                                _promoMuted),
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          }))
                                                ],
                                              );
                                            }),
                                      ],
                                    ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: _PromoCodesEmptyState(
        title: 'No promo codes used yet',
        body:
            'Promo or voucher codes used for Premium Membership value will appear here.',
      ),
    );
  }
}

class _PromoCodesEmptyState extends StatelessWidget {
  const _PromoCodesEmptyState({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _promoBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _promoPrimaryBlue.withValues(alpha: 0.10),
                  _promoCtaCyan.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: _promoPrimaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _promoNavy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Sans',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _promoMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sans',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.maybePop(context);
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_promoPrimaryBlue, _promoCtaCyan],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _promoPrimaryBlue.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Sans',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
