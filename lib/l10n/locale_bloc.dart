import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_piiink/common/app_variables.dart';
import 'package:new_piiink/constants/pref.dart';
import '../models/response/get_lang_res_model.dart';
import 'locales.dart';
import 'services/dio_lang.dart';
part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState(L10n.all[0])) {
    loadLocale();
    getLocaleData();
  }

  static const String _defaultLanguageCode = 'en';

  void changeLocale(LocaleModel localeModel) async {
    final langCode = _normaliseLanguageCode(localeModel.locale.languageCode) ??
        _defaultLanguageCode;
    await Pref().writeData(key: 'locale', value: langCode);
    AppVariables.selectedLanguageNow = langCode;
    if (AppVariables.accessToken != null) {
      await DioLang().postChoosenLang();
      //dynamic patchLangRes =
      // log('Log from locale $patchLangRes');
    }
    // localeModel.locale.languageCode;
    //For Loading BestOffers,NearbyOffers,PopularOffers
    AppVariables.locationEnabledStatus.value++;
    emit(LocaleState(localeModel));
  }

  Future<void> loadLocale() async {
    final langCode =
        _normaliseLanguageCode(await Pref().readData(key: 'locale'));
    final localeModel = _localeModelForCode(langCode);

    if (localeModel != null) {
      final selectedCode = localeModel.locale.languageCode;
      AppVariables.selectedLanguageNow = selectedCode;
      AppVariables.localeList.add(selectedCode);
      emit(LocaleState(localeModel));
      return;
    }

    AppVariables.selectedLanguageNow = _defaultLanguageCode;
    AppVariables.localeList.add(_defaultLanguageCode);
    await Pref().writeData(key: 'locale', value: _defaultLanguageCode);
    emit(LocaleState(_defaultLocaleModel));
  }

  Future<void> getLocaleData() async {
    GetLangResModel? langData = await DioLang().getLangData();
    // log(langData!.data.toString());
    AppVariables.localeList.add(_defaultLanguageCode);

    for (Datum locale in langData?.data ?? []) {
      // log(locale.lang!);
      final langCode = _normaliseLanguageCode(locale.lang);
      if (langCode != null) {
        AppVariables.localeList.add(langCode);
      }
    }
  }

  LocaleModel get _defaultLocaleModel {
    return _localeModelForCode(_defaultLanguageCode) ?? L10n.all[0];
  }

  LocaleModel? _localeModelForCode(String? langCode) {
    if (langCode == null) return null;
    for (final localeModel in L10n.all) {
      if (localeModel.locale.languageCode == langCode) {
        return localeModel;
      }
    }
    return null;
  }

  String? _normaliseLanguageCode(String? langCode) {
    final normalised = langCode?.trim().toLowerCase();
    return normalised == null || normalised.isEmpty ? null : normalised;
  }
}
