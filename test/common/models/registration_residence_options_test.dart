import 'package:flutter_test/flutter_test.dart';
import 'package:touristsaver/common/models/registration_residence_options.dart';
import 'package:touristsaver/models/response/residence_country_res_model.dart';

void main() {
  const countries = [
    ResidenceCountry(
      id: 3,
      countryName: 'Australia',
      isoAlpha2: 'AU',
      isoAlpha3: 'AUS',
      collectResidentialPostalCode: true,
      residentialPostalCodeRequired: true,
    ),
    ResidenceCountry(
      id: 4,
      countryName: 'Germany',
      isoAlpha2: 'DE',
      isoAlpha3: 'DEU',
      collectResidentialPostalCode: false,
      residentialPostalCodeRequired: false,
    ),
    ResidenceCountry(
      id: 1,
      countryName: 'Afghanistan',
      isoAlpha2: 'AF',
      isoAlpha3: 'AFG',
      collectResidentialPostalCode: false,
      residentialPostalCodeRequired: false,
    ),
    ResidenceCountry(
      id: 2,
      countryName: 'Albania',
      isoAlpha2: 'AL',
      isoAlpha3: 'ALB',
      collectResidentialPostalCode: false,
      residentialPostalCodeRequired: false,
    ),
  ];

  test('pins membership country while retaining its alphabetical entry', () {
    final options = registrationResidenceOptions(
      countries: countries,
      membershipCountryIso2: 'au',
    );
    expect(options.map((country) => country.countryName), [
      'Australia',
      'Afghanistan',
      'Albania',
      'Australia',
      'Germany',
    ]);
    expect(options.first.id, options[3].id);
    expect(options.first.collectResidentialPostalCode, isTrue);
  });

  test('leaves full alphabetical list when membership country is unavailable',
      () {
    final options = registrationResidenceOptions(
      countries: countries,
      membershipCountryIso2: 'NZ',
    );
    expect(options.map((country) => country.countryName), [
      'Afghanistan',
      'Albania',
      'Australia',
      'Germany',
    ]);
  });
}
