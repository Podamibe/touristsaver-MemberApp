import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../common/widgets/custom_app_bar.dart';
import '../../../constants/style.dart';
import 'package:touristsaver/generated/l10n.dart';

class AboutScreen extends StatefulWidget {
  static const String routeName = "/about-screen";
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _version;
  String? _build;

  _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    final build = packageInfo.buildNumber;

    setState(() {
      _version = version;
      _build = build;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getAppVersion();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: S.of(context).about,
          //about,
          icon: Icons.arrow_back_ios,
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          // Version
          Center(
            child: AutoSizeText(
              '${S.of(context).version} :  $_version+${_build ?? ''} ',
              style: profileListStyle,
            ),
          ),
        ],
      ),
    );
  }
}
