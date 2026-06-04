import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touristsaver/common/app_variables.dart';
import 'package:touristsaver/constants/pref.dart';
import '../models/response/get_lang_res_model.dart';
import 'locales.dart';
import 'services/dio_lang.dart';
part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState(L10n.all[0])) {
    loadLocale();
    getLocaleData();
  }

  void changeLocale(LocaleModel localeModel) async {
    await Pref()
        .writeData(key: 'locale', value: localeModel.locale.languageCode);
    AppVariables.selectedLanguageNow = await Pref().readData(key: 'locale');
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
    final langCode = await Pref().readData(key: 'locale');
    if (langCode != null) {
      AppVariables.selectedLanguageNow = langCode;
      LocaleModel localeModel =
          L10n.all.firstWhere((e) => e.locale.languageCode == langCode);
      AppVariables.localeList.add(langCode);
      emit(LocaleState(localeModel));
    }
  }

  Future<void> getLocaleData() async {
    GetLangResModel? langData = await DioLang().getLangData();
    // log(langData!.data.toString());
    for (Datum locale in langData!.data ?? []) {
      // log(locale.lang!);
      AppVariables.localeList.add(locale.lang!.toLowerCase());
    }
  }
}
