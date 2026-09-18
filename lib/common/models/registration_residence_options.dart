import 'package:touristsaver/models/response/residence_country_res_model.dart';

List<ResidenceCountry> registrationResidenceOptions({
  required List<ResidenceCountry> countries,
  required String? membershipCountryIso2,
}) {
  final sorted = [...countries]..sort((a, b) =>
      a.countryName.toLowerCase().compareTo(b.countryName.toLowerCase()));
  final iso2 = membershipCountryIso2?.trim().toUpperCase();
  if (iso2 == null || iso2.isEmpty) return sorted;
  for (final country in sorted) {
    if (country.isoAlpha2 == iso2) {
      return [country, ...sorted];
    }
  }
  return sorted;
}
