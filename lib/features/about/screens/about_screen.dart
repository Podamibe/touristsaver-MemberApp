import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../common/widgets/custom_app_bar.dart';
import 'package:touristsaver/generated/l10n.dart';

const Color _aboutNavy = Color(0xFF111C44);
const Color _aboutMuted = Color(0xFF63708A);
const Color _aboutBorder = Color(0xFFE5EAF4);
const Color _aboutPrimaryBlue = Color(0xFF0009FE);
const Color _aboutCtaCyan = Color(0xFF18C6FF);

class AboutScreen extends StatefulWidget {
  static const String routeName = "/about-screen";
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _version;

  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;

    if (!mounted) return;
    setState(() {
      _version = version;
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
      backgroundColor: const Color(0xFFF8FAFE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AboutCard(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_aboutPrimaryBlue, _aboutCtaCyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _aboutPrimaryBlue.withValues(alpha: 0.16),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.travel_explore_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AutoSizeText(
                      'TouristSaver',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _aboutNavy,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const AutoSizeText(
                      'Discover local savings and experiences',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _aboutMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _VersionPill(version: _version),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const _AboutCard(
                child: _AboutSection(
                  title: 'About TouristSaver',
                  body:
                      'TouristSaver helps connect members with verified local deals, dining, shopping and experiences while supporting local businesses and tourism communities.',
                ),
              ),
              const SizedBox(height: 14),
              const _AboutCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AboutSection(
                      title: 'Developed By',
                      body: 'Saver Saver Pty Ltd\nAustralia',
                    ),
                    SizedBox(height: 18),
                    _AboutSection(
                      title: 'Support',
                      body: 'support@touristsaver.org\nwww.touristsaver.org',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const AutoSizeText(
                'TouristSaver is an initiative by Saver Saver Pty Ltd.',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _aboutMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _aboutBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _VersionPill extends StatelessWidget {
  const _VersionPill({required this.version});

  final String? version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _aboutPrimaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _aboutPrimaryBlue.withValues(alpha: 0.10)),
      ),
      child: AutoSizeText(
        'Version ${version ?? ''}'.trim(),
        maxLines: 1,
        style: const TextStyle(
          color: _aboutNavy,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          title,
          maxLines: 1,
          style: const TextStyle(
            color: _aboutNavy,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        AutoSizeText(
          body,
          style: const TextStyle(
            color: _aboutMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
