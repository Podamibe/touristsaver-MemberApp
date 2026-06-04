import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:touristsaver/models/response/common_res.dart';

import '../../common/app_variables.dart';
import '../../common/utils.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_container_box.dart';
import '../../common/widgets/custom_loader.dart';
import '../../common/widgets/custom_snackbar.dart';
import '../../constants/global_colors.dart';
import '../../constants/pref.dart';
import '../../constants/style.dart';
import '../../models/response/notification_model.dart';
import 'no_notifications_available_widget.dart';
import 'services/dio_notification.dart';
import 'package:touristsaver/generated/l10n.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = false;
  bool isDeleteCalled = false;
  bool isDeletedAllCalled = false;
  int? selectedIndex;
  List<Data> notifications = [];
  String lastThreeMonthsRangeForApiCall = getLastThreeMonthsRange();
  String lastThreeMonthsRangeForUi = getLastThreeMonthsRange(forApiCall: false);
  late String startDate;
  late String endDate;

  //Delete Count
  int countDelete = 0;

  getAllNotifications() async {
    setState(() {
      isLoading = true;
    });
    var res = await DioNotification()
        .getAllNotifications(lastThreeMonthsRangeForApiCall);
    setState(() {
      isLoading = false;
    });
    if (res is NotificationModel) {
      notifications = res.data ?? [];
      AppVariables.notificationLabel.value = 0;
      await Pref().writeInt(key: 'notificationsCount', value: 0);
    } else {
      if (!mounted) return;
      GlobalSnackBar.showError(
          context, S.of(context).couldNotReceiveNotifications);
    }
  }

  @override
  void initState() {
    getAllNotifications();
    startDate = lastThreeMonthsRangeForUi.split(':').first;
    endDate = lastThreeMonthsRangeForUi.split(':').last;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar2(
          text: S.of(context).notifications,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icons.arrow_back_ios,
          deleteWidget: const ClipRRect(
            child: Icon(
              Icons.delete_forever,
              color: GlobalColors.appColor,
            ),
          ),
          onDeleteTap: () async {
            await _confirmDeleteAllNotifications();
            getAllNotifications();
            setState(() {});
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CustomAllLoader1())
          : notifications.isEmpty
              ? NoNotificationsAvailableWidget(
                  startDate: startDate, endDate: endDate)
              : Column(
                  children: [
                    CustomContainerBox(
                      padVer: 15,
                      child: AutoSizeText(
                        S
                            .of(context)
                            .notificationsFromAtoB
                            .replaceAll('&A', startDate)
                            .replaceAll('&B', endDate),
                        textAlign: TextAlign.center,
                        style: notiHeaderTextStyle,
                      ),
                      // AutoSizeText.rich(
                      //   TextSpan(
                      //     text: 'Notifications from:\n',
                      //     style: notiHeaderTextStyle,
                      //     children: [
                      //       TextSpan(
                      //         text: startDate,
                      //         style: notiHeaderTextStyle.copyWith(
                      //             color: GlobalColors.appColor),
                      //       ),
                      //       TextSpan(
                      //         text: ' to ',
                      //         style: notiHeaderTextStyle,
                      //       ),
                      //       TextSpan(
                      //         text: endDate,
                      //         style: notiHeaderTextStyle.copyWith(
                      //             color: GlobalColors.appColor),
                      //       ),
                      //     ],
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                    ),
                    Expanded(
                      child: ListView.separated(
                          separatorBuilder: (BuildContext context, index) {
                            return const SizedBox(height: 1);
                          },
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return CustomContainerBox(
                              padVer: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Transaction Successful Text
                                  AutoSizeText(
                                    notification.title ?? '',
                                    style: notiHeaderTextStyle,
                                    maxLines: 1,
                                  ),

                                  const SizedBox(height: 10),

                                  //Transaction Successful Message
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.content ?? '',
                                          style: notiSubHeaderTextStyle,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          selectedIndex = index;
                                          setState(() {
                                            isDeleteCalled = true;
                                          });
                                          var res = await DioNotification()
                                              .deleteSingleNotification(
                                                  notification.id!);
                                          if (res is CommonResModel) {
                                            setState(() {
                                              notifications.removeAt(index);
                                              isDeleteCalled = false;
                                              GlobalSnackBar.showSuccess(
                                                  context,
                                                  S
                                                      .of(context)
                                                      .notificationsDeletedSuccessfully);
                                            });
                                          } else {
                                            setState(() {
                                              isDeleteCalled = false;
                                              GlobalSnackBar.showError(
                                                  context,
                                                  S
                                                      .of(context)
                                                      .issueInDeletingNotifications);
                                            });
                                          }
                                        },
                                        icon: isDeleteCalled &&
                                                selectedIndex == index
                                            ? const CustomAllLoader1()
                                            : const Icon(Icons.delete),
                                        iconSize: 26.h,
                                        color: GlobalColors.appColor,
                                      )
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 5,
                                  ),

                                  AutoSizeText(
                                    notification.createdAt == null
                                        ? ''
                                        : convertToLocalDateTime(
                                            notification.createdAt!),
                                    style: notiDateTextStyle,
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                ),
    );
  }

  Future<void> _confirmDeleteAllNotifications() async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          bool deleteAllConfirmed = false;
          return AlertDialog(
            title: Text(
                textAlign: TextAlign.center,
                maxLines: 2,
                S.of(context).areYouSureYouWantToDeleteAllNotifications),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    deleteAllConfirmed == true
                        ? const CustomButtonWithCircular()
                        : CustomButton(
                            onPressed: () async {
                              if (notifications.isNotEmpty) {
                                setState(() {
                                  deleteAllConfirmed = true;
                                });
                                var res = await DioNotification()
                                    .deleteAllNotifications();
                                if (res is CommonResModel) {
                                  notifications.clear;
                                  if (!mounted) return;
                                  GlobalSnackBar.showSuccess(
                                      context,
                                      S
                                          .of(context)
                                          .notificationsDeletedSuccessfully);
                                } else {
                                  if (!mounted) return;
                                  GlobalSnackBar.showError(
                                      context,
                                      S
                                          .of(context)
                                          .issueInDeletingNotifications);
                                }
                              }
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            text: S.of(context).ok),
                    const SizedBox(
                      height: 5,
                    ),
                    CustomButton1(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: S.of(context).cancel)
                  ],
                ),
              );
            }),
          );
        });
  }
}
