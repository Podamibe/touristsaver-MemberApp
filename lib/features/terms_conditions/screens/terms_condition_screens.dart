import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:touristsaver/common/widgets/custom_app_bar.dart';
import 'package:touristsaver/common/widgets/error.dart';
import 'package:touristsaver/common/widgets/touristsaver_loading_view.dart';
import 'package:touristsaver/features/terms_conditions/bloc/agreement_blocs.dart';
import 'package:touristsaver/features/terms_conditions/bloc/agreement_events.dart';
import 'package:touristsaver/features/terms_conditions/bloc/agreement_states.dart';
import 'package:touristsaver/features/terms_conditions/services/dio_agreement.dart';
// import 'package:touristsaver/features/terms_conditions/widgets/fade_end_text.dart';
import 'package:touristsaver/models/response/agreement_res.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:touristsaver/generated/l10n.dart';

const Color _termsPrimaryBlue = Color(0xFF0009FE);
const Color _termsCtaCyan = Color(0xFF18C6FF);

class TermsConditionScreen extends StatefulWidget {
  static const String routeName = "/terms-condition";
  const TermsConditionScreen({super.key});

  @override
  State<TermsConditionScreen> createState() => _TermsConditionScreenState();
}

class _TermsConditionScreenState extends State<TermsConditionScreen> {
  // String acceptForOne =
  //     'true'; //to check whether the user as accepted policy or not
  // bool isLoading = false;

  //To show the back to top button
  bool backToTop = false;
  late ScrollController scrollController;

  // String? _version;
  // String? _build;

  // void _getAppVersion() async {
  //   final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  //   final version = packageInfo.version;
  //   final build = packageInfo.buildNumber;

  //   setState(() {
  //     _version = version;
  //     _build = build;
  //   });
  // }

  @override
  void initState() {
    // _getAppVersion();
    scrollController = ScrollController()
      ..addListener(() {
        final maxScroll = scrollController.position.maxScrollExtent;
        setState(() {
          // if (scrollController.position.atEdge) {
          if (scrollController.offset >= maxScroll) {
            // bool isTop = scrollController.position.pixels == 0;
            // if (isTop) {
            // backToTop = false;
            backToTop = true;
          } else {
            // backToTop = true;
            backToTop = false;
          }
          // }
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  //function that gets triggered when user clicks back to top button
  void scrollToTop() {
    scrollController.animateTo(0,
        duration: const Duration(seconds: 1), curve: Curves.linear);
  }

  //function that gets triggered when user clicks top to back button
  void scrollTobutton() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        // child: acc != 'true'
        //     ? CustomAppBar(text: terms)
        //     : CustomAppBar(
        //         text: terms,
        //         icon: Icons.arrow_back_ios,
        //         onPressed: () {
        //           Navigator.pop(context);
        //         },
        //       ),
        child: CustomAppBar(
          text: S.of(context).termsConditions,
          icon: Icons.arrow_back_ios,
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: const ScrollBehavior(),
            child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 100.0, top: 10.0),
                scrollDirection: Axis.vertical,
                child: BlocProvider(
                  lazy: false,
                  create: (context) => AgreementBloc(
                      RepositoryProvider.of<DioAgreement>(context))
                    ..add(LoadAgreementEvent()),
                  child: BlocBuilder<AgreementBloc, AgreementState>(
                    builder: (context, state) {
                      //Loading State
                      if (state is AgreementLoadingState) {
                        return const TouristSaverLoadingView();
                      }
                      // Loaded State
                      else if (state is AgreementLoadedState) {
                        AgreementResModel agreement = state.agreement;
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              apiTermsAndCondition(agreement.data!.description),
                            ]);
                      }
                      //Error State
                      else if (state is AgreementErrorState) {
                        return const Error();
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                )),
          ),

          // // Fading text
          // backToTop == false
          //     ? const SizedBox()
          //     : acc == 'true'
          //         ? const SizedBox()
          //         : const FadeEndText(),
        ],
      ),

      // Accept Button
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //Back To Top floating action button
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: backToTop == false ? scrollTobutton : scrollToTop,
              child: Ink(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_termsPrimaryBlue, _termsCtaCyan],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _termsPrimaryBlue.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: Icon(
                  backToTop == false
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // From Api Terms and Condition
  apiTermsAndCondition(String? description) {
    //HTML Starts
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Html(
        data: description,
        onLinkTap: (url, _, __) async {
          if (Platform.isIOS) {
            await launchUrlString(
              url.toString(),
              mode: LaunchMode.externalApplication,
            );
          } else {
            await launchUrlString(
              url.toString(),
              mode: LaunchMode.externalNonBrowserApplication,
            );
          }
        },
      ),
    );
  }
}
