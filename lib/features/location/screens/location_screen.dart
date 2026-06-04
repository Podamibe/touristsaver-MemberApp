import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/custom_loader.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/constants/global_colors.dart';
import 'package:touristsaver/constants/pref.dart';
import 'package:touristsaver/constants/pref_key.dart';
import 'package:touristsaver/constants/style.dart';
import 'package:touristsaver/features/connectivity/cubit/internet_cubit.dart';
import 'package:touristsaver/features/location/bloc/location_all_blocs.dart';
import 'package:touristsaver/features/location/bloc/location_all_events.dart';
import 'package:touristsaver/features/location/bloc/location_all_states.dart';
import 'package:touristsaver/features/location/services/dio_location.dart';
import 'package:touristsaver/features/terms_conditions/widgets/fade_end_text.dart';
import 'package:touristsaver/models/response/location_get_all.dart';
import 'package:touristsaver/models/response/region_get_all.dart'
    as region_get_all;
import 'package:touristsaver/models/response/state_get_all.dart'
    as state_get_all;

import '../../connectivity/screens/connectivity.dart';
import '../../connectivity/screens/connectivity_screen.dart';
import 'package:touristsaver/generated/l10n.dart';

class LocationScreen extends StatefulWidget {
  static const String routeName = "/location";
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // List<Datum> searchlocation = [];

  // to select
  String? locationSelected; //For name to be shown in homepage
  int?
      locationSelectedID; //For showing the selected icon in location screen (this)
  // To expand when selecting
  int? countrySelected;
  int? stateSelected;
  int? countrySearchedSelected;
  int? stateSearchedSelected;
  // For calling api and saving the selected location id
  int? selectedCountryID;
  int? selectedStateID;
  int? selectedRegionID;

  checkAllID() async {
    selectedCountryID =
        int.parse(await Pref().readData(key: userChosenLocationID));

    locationSelected = await Pref().readData(key: userChosenCountryStateName);

    selectedStateID =
        await Pref().readData(key: userChosenLocationStateID) == 'null' ||
                await Pref().readData(key: userChosenLocationStateID) == '0' ||
                await Pref().readData(key: userChosenLocationStateID) == null
            ? 0
            : int.parse(await Pref().readData(key: userChosenLocationStateID));

    selectedRegionID =
        await Pref().readData(key: userChosenLocationRegionID) == 'null' ||
                await Pref().readData(key: userChosenLocationRegionID) == '0' ||
                await Pref().readData(key: userChosenLocationRegionID) == null
            ? 0
            : int.parse(await Pref().readData(key: userChosenLocationRegionID));

    if (selectedCountryID != 0 &&
        selectedStateID == 0 &&
        selectedRegionID == 0) {
      setState(() {
        locationSelectedID = selectedCountryID;
        stateList = getState();
      });
      return;
    } else if (selectedCountryID != 0 &&
        selectedStateID != 0 &&
        selectedRegionID == 0) {
      setState(() {
        locationSelectedID = selectedStateID;
        stateList = getState();
        regionList = getRegion();
      });
      return;
    } else {
      setState(() {
        locationSelectedID = selectedRegionID;
        stateList = getState();
        regionList = getRegion();
      });
      return;
    }
  }

  // Getting State
  Future<state_get_all.StateGetAllResModel?>? stateList;
  Future<state_get_all.StateGetAllResModel?> getState() async {
    state_get_all.StateGetAllResModel? stateGetAllResModel =
        await DioLocation().getAllState(countryID: selectedCountryID!);
    searchStateResult.addAll(stateGetAllResModel!.data!);

    return stateGetAllResModel;
  }

  // Getting Region
  Future<region_get_all.RegionGetAllResModel?>? regionList;
  Future<region_get_all.RegionGetAllResModel?> getRegion() async {
    region_get_all.RegionGetAllResModel? regionGetAllResModel =
        await DioLocation().getAllRegion(
            countryId: selectedCountryID!, stateId: selectedStateID!);
    searchRegionResult.addAll(regionGetAllResModel!.data!);

    return regionGetAllResModel;
  }

  //For Search
  final TextEditingController searchController = TextEditingController();
  final searchKey = GlobalKey<FormState>();
  bool isSearching = false;
  String searchText = "";
  List<Datum> searchResult = [];
  List<state_get_all.Datum> searchStateResult = [];
  List<region_get_all.Datum> searchRegionResult = [];

  _LocationScreenState() {
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        setState(() {
          isSearching = false;
          searchText = "";
          // stateSelected = -1;
          // countrySelected = -1;
          // stateSearchedSelected = -1;
          // countrySearchedSelected = -1;
        });
      } else {
        setState(() {
          isSearching = true;
          searchText = searchController.text;
          // stateSelected = -1;
        });
      }
    });
  }

  @override
  void initState() {
    checkAllID();
    super.initState();
  }

  @override
  void dispose() {
    ConnectivityCubit().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
            text: S.of(context).location,
            icon: Icons.arrow_back_ios,
            onPressed: () {
              context.pop();
            }),
      ),
      body: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
          if (state == ConnectivityState.loading) {
            return const NoInternetLoader();
          } else if (state == ConnectivityState.disconnected) {
            return const NoConnectivityScreen();
          } else if (state == ConnectivityState.connected) {
            return Stack(
              children: [
                ScrollConfiguration(
                  behavior: const ScrollBehavior(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 100),
                      child: BlocProvider(
                        lazy: false,
                        create: (context) => LocationAllBloc(
                            RepositoryProvider.of<DioLocation>(context))
                          ..add(LoadLocationAllEvent()),
                        child: BlocBuilder<LocationAllBloc, LocationAllState>(
                            builder: (context, state) {
                          // Loading State
                          if (state is LocationAllLoadingState) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                notifyUser(),
                                const SizedBox(height: 20),
                                AutoSizeText(
                                  S
                                      .of(context)
                                      .searchOrChooseCountryStateRegionFromTheListBelowToFilterOffersAndMerchants,
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Colors.black.withValues(alpha: 0.8)),
                                ),
                                const SizedBox(height: 25),
                                // Search
                                Container(
                                  width: MediaQuery.of(context).size.width / 1,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                        color: GlobalColors.appColor
                                            .withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.search,
                                        size: 30,
                                        color: GlobalColors.gray,
                                      ),
                                      const SizedBox(width: 5),
                                      // TextFormField
                                      Form(
                                        key: searchKey,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.3,
                                          child: TextFormField(
                                            controller: searchController,
                                            cursorColor: GlobalColors.appColor,
                                            decoration: textInputDecoration,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Center(
                                  child: CustomAllLoader(),
                                ),
                              ],
                            );
                          }
                          // Loaded State
                          else if (state is LocationAllLoadedState) {
                            LocationGetAllResModel locationList =
                                state.locationGetAll;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //Notify Note Text
                                notifyUser(),

                                const SizedBox(height: 20),

                                //Search or Choose Text
                                AutoSizeText(
                                  S
                                      .of(context)
                                      .searchOrChooseCountryStateRegionFromTheListBelowToFilterOffersAndMerchants,
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Colors.black.withValues(alpha: 0.8)),
                                ),
                                const SizedBox(height: 25),

                                // Search
                                Container(
                                  width: MediaQuery.of(context).size.width / 1,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                        color: GlobalColors.appColor
                                            .withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.search,
                                        size: 30,
                                        color: GlobalColors.gray,
                                      ),
                                      const SizedBox(width: 5),
                                      // TextFormField
                                      Form(
                                        key: searchKey,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.3,
                                          child: TextFormField(
                                              controller: searchController,
                                              cursorColor:
                                                  GlobalColors.appColor,
                                              decoration: textInputDecoration,
                                              onTap: () {
                                                setState(() {
                                                  isSearching = true;
                                                });
                                              },
                                              onChanged: (value) {
                                                searchOperation(
                                                    searchController.text
                                                        .trim(),
                                                    locationList.data!);
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Location List
                                locationList.data!.isEmpty
                                    ? AutoSizeText(
                                        S
                                            .of(context)
                                            .noAnyCountryOrStateOrRegion,
                                      )
                                    : listOfLocation(locationList),
                              ],
                            );
                          }
                          // Error State
                          else if (state is LocationAllErrorState) {
                            return const Center(
                              child: Error(),
                            );
                          }
                          // if none the state is executable
                          else {
                            return const SizedBox();
                          }
                        }),
                      ),
                    ),
                  ),
                ),
                const FadeEndText(),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),

      // Floating Action Button
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width / 1.2,
        height: 45.h,
        margin: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton.extended(
          elevation: 5,
          backgroundColor: GlobalColors.appColor1,
          onPressed: () async {
            // Removing old saved data
            // await Pref().removeData(userChosenLocationStateID);
            // await Pref().removeData(userChosenLocationRegionID);

            // Writing the new data
            // Pref().writeData(
            //     key: userChosenLocationName, value: locationSelected!);
            Pref().writeData(
                key: userChosenCountryStateName,
                value: locationSelected.toString());
            Pref().writeData(
                key: userChosenLocationID, value: selectedCountryID.toString());
            Pref().writeData(
                key: userChosenLocationStateID,
                value: selectedStateID.toString());
            Pref().writeData(
                key: userChosenLocationRegionID,
                value: selectedRegionID.toString());

            if (!mounted) return;
            // context.pop();
            context.pushReplacementNamed('bottom-bar',
                pathParameters: {'page': '1'});
          },
          heroTag: const Text("btn1"),
          label: AutoSizeText(
            S.of(context).continueL,
            style: textStyle15.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  //Notify Note Text
  notifyUser() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: GlobalColors.appWhiteBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            ),
          ]),
      child: AutoSizeText(
        S
            .of(context)
            .theChangeOfLocationInThisScreenOnlyChangesTheDisplayOfMerchantDataForChangingYourRegisteredLocationYouNeedToNavigateToTheChangeCountryAndChangeItRespectively,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black.withValues(alpha: 0.8),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Location List
  listOfLocation(LocationGetAllResModel locationList) {
    // Giving the index number of selected country
    countrySelected = locationList.data!
        .indexWhere((element) => element.id == selectedCountryID);

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: GlobalColors.appWhiteBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            ),
          ]),
      child: searchResult.isNotEmpty || searchController.text.isNotEmpty
          ? listOfSearchLocation()
          : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              key: Key('builder ${countrySelected.toString()}'),
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.black.withValues(alpha: 0.3),
                  // thickness: 2,
                );
              },
              itemCount: locationList.data!.length,
              itemBuilder: (context, index) {
                return Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ListTileTheme(
                    //To manage the height of the expansionTile
                    contentPadding: const EdgeInsets.only(
                        right: 0, top: 0, bottom: 0, left: 10),
                    dense: true,
                    child: ExpansionTile(
                      collapsedTextColor: Colors.black,
                      textColor: Colors.black,
                      iconColor: GlobalColors.appColor,
                      collapsedIconColor: GlobalColors.appColor,
                      key: Key(index.toString()), //attention
                      controlAffinity: ListTileControlAffinity.leading,
                      initiallyExpanded: index == countrySelected,
                      onExpansionChanged: (value) {
                        final locationID = locationList.data!.firstWhere(
                            (element) =>
                                element.countryName ==
                                locationList.data![index].countryName);
                        selectedCountryID = locationID.id!;

                        if (value) {
                          setState(() {
                            countrySelected = index;
                            locationSelected =
                                locationList.data![index].countryName!;
                            locationSelectedID = locationList.data![index].id;
                            selectedStateID = 0;
                            selectedRegionID = 0;
                            stateList = getState();
                            stateSelected = -1;
                          });
                        } else {
                          setState(() {
                            locationSelected =
                                locationList.data![index].countryName!;
                            locationSelectedID = locationList.data![index].id;
                            selectedStateID = 0;
                            selectedRegionID = 0;
                            countrySelected = -1;
                          });
                        }
                      },
                      trailing: locationSelectedID ==
                              locationList.data![index].id
                          //  &&
                          //         locationSelected ==
                          //             locationList.data![index].countryName
                          ? const SizedBox(
                              width: 50,
                              child: Icon(
                                Icons.check_circle,
                                color: GlobalColors.appColor,
                                size: 25,
                              ),
                            )
                          : const SizedBox(
                              width: 50,
                            ),
                      // Country Name
                      title: AutoSizeText(
                        locationList.data![index].countryName!,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      children: [
                        FutureBuilder<state_get_all.StateGetAllResModel?>(
                          future: stateList,
                          builder: (context, snapshot1) {
                            if (!snapshot1.hasData) {
                              return const SizedBox();
                            } else {
                              // Giving the index number of selected state
                              stateSelected = snapshot1.data!.data!.indexWhere(
                                (element) => element.id == selectedStateID,
                              );
                              return snapshot1.data!.data!.isEmpty
                                  ? SizedBox(
                                      child: AutoSizeText(
                                        S.of(context).noStateAvailable,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  : ListView.separated(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      key: Key(
                                          'builder ${stateSelected.toString()}'),
                                      separatorBuilder: (context, index1) {
                                        return const Divider(
                                          height: 10,
                                          color: GlobalColors
                                              .appGreyBackgroundColor,
                                          thickness: 2,
                                        );
                                      },
                                      itemCount: snapshot1.data!.data!.length,
                                      itemBuilder: (context, index1) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                              dividerColor: Colors.transparent),
                                          child: ListTileTheme(
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    right: 0,
                                                    top: 0,
                                                    bottom: 0,
                                                    left: 30),
                                            dense: true,
                                            horizontalTitleGap: 10.0,
                                            child: ExpansionTile(
                                              collapsedTextColor: Colors.black,
                                              textColor: Colors.black,
                                              iconColor: GlobalColors.appColor,
                                              collapsedIconColor:
                                                  GlobalColors.appColor,
                                              key: Key(index1
                                                  .toString()), //attention
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading, //To bring the leading icon in front
                                              initiallyExpanded:
                                                  index1 == stateSelected,
                                              onExpansionChanged: (value) {
                                                final stateID = snapshot1
                                                    .data!.data!
                                                    .firstWhere((element) =>
                                                        element.stateName ==
                                                        snapshot1
                                                            .data!
                                                            .data![index1]
                                                            .stateName);
                                                selectedStateID = stateID.id!;
                                                if (value) {
                                                  setState(() {
                                                    stateSelected = index1;
                                                    locationSelected = snapshot1
                                                        .data!
                                                        .data![index1]
                                                        .stateName!;
                                                    locationSelectedID =
                                                        snapshot1.data!
                                                            .data![index1].id;
                                                    selectedRegionID = 0;
                                                    regionList = getRegion();
                                                  });
                                                } else {
                                                  setState(() {
                                                    locationSelected = snapshot1
                                                        .data!
                                                        .data![index1]
                                                        .stateName!;
                                                    locationSelectedID =
                                                        snapshot1.data!
                                                            .data![index1].id;
                                                    selectedRegionID = 0;
                                                    stateSelected = -1;
                                                  });
                                                }
                                              },
                                              trailing: locationSelectedID ==
                                                          snapshot1
                                                              .data!
                                                              .data![index1]
                                                              .id &&
                                                      locationSelected ==
                                                          snapshot1
                                                              .data!
                                                              .data![index1]
                                                              .stateName
                                                  ? const SizedBox(
                                                      width: 50,
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        color: GlobalColors
                                                            .appColor,
                                                        size: 25,
                                                      ),
                                                    )
                                                  : const SizedBox(
                                                      width: 50,
                                                    ),
                                              // State Name
                                              title: AutoSizeText(
                                                snapshot1.data!.data![index1]
                                                    .stateName!,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              children: [
                                                FutureBuilder<
                                                    region_get_all
                                                    .RegionGetAllResModel?>(
                                                  future: regionList,
                                                  builder:
                                                      (context, snapshot2) {
                                                    if (!snapshot2.hasData) {
                                                      return Container();
                                                    } else {
                                                      return snapshot2.data!
                                                              .data!.isEmpty
                                                          ? SizedBox(
                                                              child:
                                                                  AutoSizeText(
                                                                S
                                                                    .of(context)
                                                                    .noRegionAvailable,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            )
                                                          : ListView.separated(
                                                              physics:
                                                                  const NeverScrollableScrollPhysics(),
                                                              shrinkWrap: true,
                                                              separatorBuilder:
                                                                  (context,
                                                                      index2) {
                                                                return const Divider(
                                                                  height: 10,
                                                                  color: GlobalColors
                                                                      .appGreyBackgroundColor,
                                                                  thickness: 2,
                                                                );
                                                              },
                                                              itemCount:
                                                                  snapshot2
                                                                      .data!
                                                                      .data!
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index2) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    // print(searchResult[index]);
                                                                    setState(
                                                                        () {
                                                                      locationSelected = snapshot2
                                                                          .data!
                                                                          .data![
                                                                              index2]
                                                                          .regionName;
                                                                      locationSelectedID = snapshot2
                                                                          .data!
                                                                          .data![
                                                                              index2]
                                                                          .id;
                                                                      selectedRegionID = snapshot2
                                                                          .data!
                                                                          .data![
                                                                              index2]
                                                                          .id;
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: GlobalColors
                                                                          .appWhiteBackgroundColor,
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              100,
                                                                          right:
                                                                              15,
                                                                          top:
                                                                              10,
                                                                          bottom:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          AutoSizeText(
                                                                            // searchResult[index],
                                                                            snapshot2.data!.data![index2].regionName!,
                                                                            style:
                                                                                const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                                                          ),
                                                                          // Selected icon
                                                                          locationSelectedID == snapshot2.data!.data![index2].id && locationSelected == snapshot2.data!.data![index2].regionName
                                                                              ? const Icon(
                                                                                  Icons.check_circle,
                                                                                  color: GlobalColors.appColor,
                                                                                  size: 25,
                                                                                )
                                                                              : const SizedBox(),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  listOfSearchLocation() {
    // Giving the index number of selected country
    countrySearchedSelected =
        searchResult.indexWhere((element) => element.id == selectedCountryID);

    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: GlobalColors.appWhiteBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(2, 2),
              ),
            ]),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          key: Key('builder ${countrySearchedSelected.toString()}'),
          separatorBuilder: (context, index) {
            return Divider(
              // height: 10,
              color: Colors.black.withValues(alpha: 0.3),
              // thickness: 2,
            );
          },
          itemCount: searchResult.length,
          itemBuilder: (context, index) {
            return Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ListTileTheme(
                //To manage the height of the expansionTile
                contentPadding: const EdgeInsets.only(
                    right: 0, top: 0, bottom: 0, left: 10),
                dense: true, //removes additional space vertically
                horizontalTitleGap: 10.0,
                child: ExpansionTile(
                  collapsedTextColor: Colors.black,
                  textColor: Colors.black,
                  iconColor: GlobalColors.appColor,
                  collapsedIconColor: GlobalColors.appColor,
                  key: Key(index.toString()), //attention
                  controlAffinity: ListTileControlAffinity
                      .leading, //To bring the leading icon in front
                  initiallyExpanded: index == countrySearchedSelected,
                  onExpansionChanged: (value) {
                    final locationID = searchResult.firstWhere((element) =>
                        element.countryName == searchResult[index].countryName);
                    selectedCountryID = locationID.id;

                    if (value) {
                      setState(() {
                        countrySearchedSelected = index;
                        locationSelected = searchResult[index].countryName!;
                        locationSelectedID = searchResult[index].id;
                        selectedStateID = 0;
                        selectedRegionID = 0;
                        searchStateResult.clear();
                        stateList = getState();
                        // stateSearchedSelected = -1;
                      });
                    } else {
                      setState(() {
                        locationSelected = searchResult[index].countryName!;
                        locationSelectedID = searchResult[index].id;
                        selectedStateID = 0;
                        selectedRegionID = 0;
                        countrySearchedSelected = -1;
                      });
                    }
                  },
                  trailing: locationSelectedID == searchResult[index].id &&
                          locationSelected == searchResult[index].countryName
                      ? const SizedBox(
                          width: 50,
                          child: Icon(
                            Icons.check_circle,
                            color: GlobalColors.appColor,
                            size: 25,
                          ),
                        )
                      : const SizedBox(
                          width: 50,
                        ),
                  // Country Name
                  title: AutoSizeText(
                    searchResult[index].countryName!,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  children: [
                    FutureBuilder<state_get_all.StateGetAllResModel?>(
                        future: stateList,
                        builder: (context, snapshot1) {
                          if (!snapshot1.hasData) {
                            return Container();
                          } else {
                            // Giving the index number of selected state
                            stateSearchedSelected =
                                searchStateResult.indexWhere(
                              (element) => element.id == selectedStateID,
                            );
                            return searchStateResult.isEmpty
                                ? SizedBox(
                                    child: AutoSizeText(
                                      S.of(context).noStateAvailable,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : ListView.separated(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    key: Key(
                                        'builder ${stateSearchedSelected.toString()}'),
                                    separatorBuilder: (context, index1) {
                                      return const Divider(
                                        height: 10,
                                        color:
                                            GlobalColors.appGreyBackgroundColor,
                                        thickness: 2,
                                      );
                                    },
                                    itemCount: searchStateResult.length,
                                    itemBuilder: (context, index1) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                            dividerColor: Colors.transparent),
                                        child: ListTileTheme(
                                          contentPadding: const EdgeInsets.only(
                                              right: 0,
                                              top: 0,
                                              bottom: 0,
                                              left: 30),
                                          dense: true,
                                          horizontalTitleGap: 10.0,
                                          child: ExpansionTile(
                                            collapsedTextColor: Colors.black,
                                            textColor: Colors.black,
                                            iconColor: GlobalColors.appColor,
                                            collapsedIconColor:
                                                GlobalColors.appColor,
                                            key: Key(
                                                index1.toString()), //attention
                                            controlAffinity: ListTileControlAffinity
                                                .leading, //To bring the leading icon in front
                                            initiallyExpanded:
                                                index1 == stateSearchedSelected,
                                            onExpansionChanged: (value) {
                                              final stateID = snapshot1
                                                  .data!.data!
                                                  .firstWhere((element) =>
                                                      element.stateName ==
                                                      searchStateResult[index1]
                                                          .stateName);
                                              selectedStateID = stateID.id!;

                                              if (value) {
                                                setState(() {
                                                  stateSearchedSelected =
                                                      index1;
                                                  locationSelected =
                                                      searchStateResult[index1]
                                                          .stateName!;
                                                  locationSelectedID =
                                                      searchStateResult[index1]
                                                          .id;
                                                  selectedRegionID = 0;
                                                  searchRegionResult.clear();
                                                  regionList = getRegion();
                                                });
                                              } else {
                                                setState(() {
                                                  locationSelected =
                                                      searchStateResult[index1]
                                                          .stateName!;
                                                  locationSelectedID =
                                                      searchStateResult[index1]
                                                          .id;
                                                  selectedRegionID = 0;
                                                  stateSearchedSelected = -1;
                                                });
                                              }
                                            },
                                            trailing: locationSelectedID ==
                                                        searchStateResult[
                                                                index1]
                                                            .id &&
                                                    locationSelected ==
                                                        searchStateResult[
                                                                index1]
                                                            .stateName
                                                ? const SizedBox(
                                                    width: 50,
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color:
                                                          GlobalColors.appColor,
                                                      size: 25,
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    width: 50,
                                                  ),
                                            // State Name
                                            title: AutoSizeText(
                                              searchStateResult[index1]
                                                  .stateName!,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            children: [
                                              FutureBuilder<
                                                      region_get_all
                                                      .RegionGetAllResModel?>(
                                                  future: regionList,
                                                  builder:
                                                      (context, snapshot2) {
                                                    if (!snapshot2.hasData) {
                                                      return Container();
                                                    } else {
                                                      return searchRegionResult
                                                              .isEmpty
                                                          ? SizedBox(
                                                              child:
                                                                  AutoSizeText(
                                                                S
                                                                    .of(context)
                                                                    .noRegionAvailable,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            )
                                                          : ListView.separated(
                                                              physics:
                                                                  const NeverScrollableScrollPhysics(),
                                                              shrinkWrap: true,
                                                              separatorBuilder:
                                                                  (context,
                                                                      index2) {
                                                                return const Divider(
                                                                  height: 10,
                                                                  color: GlobalColors
                                                                      .appGreyBackgroundColor,
                                                                  thickness: 2,
                                                                );
                                                              },
                                                              itemCount:
                                                                  searchRegionResult
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index2) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      locationSelected =
                                                                          searchRegionResult[index2]
                                                                              .regionName;
                                                                      selectedRegionID =
                                                                          searchRegionResult[index2]
                                                                              .id;
                                                                      locationSelectedID =
                                                                          searchRegionResult[index2]
                                                                              .id;
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: GlobalColors
                                                                          .appWhiteBackgroundColor,
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              100,
                                                                          right:
                                                                              15,
                                                                          top:
                                                                              10,
                                                                          bottom:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          AutoSizeText(
                                                                            searchRegionResult[index2].regionName!,
                                                                            style:
                                                                                const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                                                          ),
                                                                          locationSelectedID == searchRegionResult[index2].id && locationSelected == searchRegionResult[index2].regionName
                                                                              ? const Icon(
                                                                                  Icons.check_circle,
                                                                                  color: GlobalColors.appColor,
                                                                                  size: 25,
                                                                                )
                                                                              : Container(),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                    }
                                                  })
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                          }
                        })
                  ],
                ),
              ),
            );
          },
        ));
  }

  // For Searching
  searchOperation(String searchText, List<Datum> locationList) {
    searchResult.clear();

    // if (isSearching != null) {
    if (searchText.isNotEmpty) {
      for (int i = 0; i < locationList.length; i++) {
        // String data = locationList[i].countryName!;
        List<Datum> data = locationList;
        if (data[i]
            .countryName!
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          searchResult.add(data[i]);
        }
      }
    }
  }
}
