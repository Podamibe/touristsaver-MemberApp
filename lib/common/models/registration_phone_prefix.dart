import 'package:country_picker/country_picker.dart';

final List<Country> _internationalCallingCountries = CountryService()
    .getAll()
    .where((country) => country.geographic && country.phoneCode.isNotEmpty)
    .toList()
  ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

class RegistrationPhonePrefixOption {
  const RegistrationPhonePrefixOption(this.country, {this.pinned = false});

  final Country country;
  final bool pinned;

  String get dialCode => '+${country.phoneCode}';
  String get key =>
      '${country.countryCode} ${country.name} $dialCode ${pinned ? 'pinned' : 'alphabetical'}';
  String get label => '${country.flagEmoji} ${country.name} $dialCode';
}

List<RegistrationPhonePrefixOption> registrationPhonePrefixOptions({
  required String? membershipCountryIso2,
}) {
  final options = _internationalCallingCountries
      .map((country) => RegistrationPhonePrefixOption(country))
      .toList();
  final pinnedIso2 = membershipCountryIso2?.trim().toUpperCase();
  if (pinnedIso2 != null && pinnedIso2.isNotEmpty) {
    for (final country in _internationalCallingCountries) {
      if (country.countryCode == pinnedIso2) {
        options.insert(0, RegistrationPhonePrefixOption(country, pinned: true));
        break;
      }
    }
  }
  return options;
}
