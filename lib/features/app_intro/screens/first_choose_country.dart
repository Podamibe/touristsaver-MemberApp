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
import 'package:touristsaver/features/location/bloc/location_all_blocs.dart';
import 'package:touristsaver/features/location/bloc/location_all_events.dart';
import 'package:touristsaver/features/location/bloc/location_all_states.dart';
import 'package:touristsaver/features/location/services/dio_location.dart';
import 'package:touristsaver/features/profile/widget/info_popup.dart';
import 'package:touristsaver/models/response/location_get_all.dart';
import 'package:touristsaver/generated/l10n.dart';

class FirstChooseCountry extends StatefulWidget {
  static const String routeName = '/first-choose-country';
  const FirstChooseCountry({super.key});

  @override
  State<FirstChooseCountry> createState() => _FirstChooseCountryState();
}

class _FirstChooseCountryState extends State<FirstChooseCountry> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar1(
          text: S.of(context).chooseCountry,
          onInfoTap: () {
            countryInfo();
          },
        ),
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: BlocProvider(
            lazy: false,
            create: (context) =>
                LocationAllBloc(RepositoryProvider.of<DioLocation>(context))
                  ..add(LoadLocationAllEvent()),
            child: BlocBuilder<LocationAllBloc, LocationAllState>(
                builder: (context, state) {
              //Loading State
              if (state is LocationAllLoadingState) {
                return const CustomAllLoader();
              }
              // Loaded State
              else if (state is LocationAllLoadedState) {
                LocationGetAllResModel countryList = state.locationGetAll;
                return allCountryList(countryList);
              }
              // Error State
              else if (state is LocationAllErrorState) {
                return const Center(
                  child: Error1(),
                );
              } else {
                return const SizedBox();
              }
            }),
          ),
        ),
      ),
    );
  }

  // Loaded State all
  allCountryList(LocationGetAllResModel countryList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
      padding: const EdgeInsets.only(
          left: 10.0, right: 10.0, bottom: 10.0, top: 10.0),
      itemCount: countryList.data!.length,
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: () {
            // Saving Chosen Country ID
            Pref().writeData(
                key: userChosenLocationID,
                value: countryList.data![index].id!.toString());
            // Saving Chosen Country Name
            Pref().writeData(
                key: userChosenLocationName,
                value: countryList.data![index].countryName.toString());

            Pref().writeData(
                key: userChosenCountryStateName,
                value: countryList.data![index].countryName.toString());

            context.pushNamed('terms-first');
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            // constraints: const BoxConstraints(
            //   //To make height expandable according to the text
            //   maxHeight: double.infinity,
            // ),
            height: 55,
            child: ListTile(
              tileColor: GlobalColors.appWhiteBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                // Country Name
                child: AutoSizeText(
                  countryList.data![index].countryName!,
                  style: topicStyle.copyWith(
                      fontWeight: FontWeight.w500, fontSize: 16.sp),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // country info
  countryInfo() {
    return showGeneralDialog(
      barrierLabel: 'Label',
      barrierDismissible: false, //to dismiss the container once opened
      barrierColor: Colors.black.withValues(
          alpha:
              0.5), //to change the background color once the container is opened
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: InfoPopUp(
            title: S.of(context).chooseCountry,
            body:
                'Please choose country so that we can show you the merchants based on your chosen country.',
            footer:
                'which will help us display best offers, popular merchants, new merchants and other merchants.',
            image: 'assets/images/shopping-bag.png',
            onOk: () {
              context.pop();
            },
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    );
  }
}
