import 'package:flutter_test/flutter_test.dart';
import 'package:touristsaver/common/models/registration_phone_prefix.dart';

void main() {
  test('travellers can choose from a complete independent calling-code list',
      () {
    final options = registrationPhonePrefixOptions(membershipCountryIso2: null);
    expect(options.length, greaterThan(200));
    expect(options.any((item) => item.label == '🇩🇪 Germany +49'), isTrue);
    expect(options.any((item) => item.label == '🇳🇿 New Zealand +64'), isTrue);
    expect(options.any((item) => item.label == '🇦🇺 Australia +61'), isTrue);
    expect(options.every((item) => !item.pinned), isTrue);
  });

  test('membership country is pinned and remains alphabetically listed', () {
    final options = registrationPhonePrefixOptions(membershipCountryIso2: 'nz');
    expect(options.first.pinned, isTrue);
    expect(options.first.label, '🇳🇿 New Zealand +64');
    final alphabeticNewZealand = options
        .where((item) => item.country.countryCode == 'NZ' && !item.pinned)
        .single;
    expect(alphabeticNewZealand.label, options.first.label);
    expect(alphabeticNewZealand.key, isNot(options.first.key));
    expect(options[1].country.name.compareTo(options[2].country.name) <= 0,
        isTrue);
  });

  test('dropdown search key contains country name and calling code', () {
    final options = registrationPhonePrefixOptions(membershipCountryIso2: 'AU');
    final germany = options.singleWhere(
        (item) => item.country.countryCode == 'DE' && !item.pinned);
    expect(germany.key.toLowerCase(), contains('germany'));
    expect(germany.key, contains('+49'));
  });
}
