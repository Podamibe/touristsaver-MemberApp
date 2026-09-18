import 'package:flutter_test/flutter_test.dart';
import 'package:touristsaver/common/models/registration_code_resolution.dart';
import 'package:touristsaver/features/register/screens/register_screen.dart';

void main() {
  test('phone structure is independent of country of residence', () {
    // A UK prefix and structurally valid mobile remain valid regardless of
    // whether the separately selected residence is Australia or elsewhere.
    expect(
      isRegistrationPhoneStructurallyValid(
        phonePrefix: '+44',
        phoneNumber: '7700900123',
      ),
      isTrue,
    );
    expect(
      isRegistrationPhoneStructurallyValid(
        phonePrefix: null,
        phoneNumber: '7700900123',
      ),
      isFalse,
    );
    expect(
      isRegistrationPhoneStructurallyValid(
        phonePrefix: '+61',
        phoneNumber: '123',
      ),
      isFalse,
    );
  });

  test('only a linked Discovery invitation hides the promo field', () {
    expect(
      shouldShowRegistrationPromoCodePanel(
        recognizedDiscoveryInvitation: true,
        registrationCode: 'DISCOVERY',
        validationFailed: false,
      ),
      isFalse,
    );
    expect(
      shouldShowRegistrationPromoCodePanel(
        recognizedDiscoveryInvitation: false,
        registrationCode: 'DISCOVERY',
        validationFailed: false,
      ),
      isTrue,
    );
    expect(
      shouldShowRegistrationPromoCodePanel(
        recognizedDiscoveryInvitation: true,
        registrationCode: null,
        validationFailed: false,
      ),
      isTrue,
    );
  });

  test('Discovery card waits for a valid Discovery resolver response', () {
    const validDiscovery = RegistrationCodeResolution(
      valid: true,
      category: RegistrationCodeCategory.discoveryInvitation,
    );
    const rejected = RegistrationCodeResolution(
      valid: false,
      category: RegistrationCodeCategory.unknown,
    );
    expect(
      shouldShowDiscoveryInvitationCard(
        recognizedDiscoveryInvitation: true,
        registrationCode: 'DISCOVERY',
        resolution: null,
        validationFailed: false,
      ),
      isFalse,
    );
    expect(
      shouldShowDiscoveryInvitationCard(
        recognizedDiscoveryInvitation: true,
        registrationCode: 'DISCOVERY',
        resolution: validDiscovery,
        validationFailed: false,
      ),
      isTrue,
    );
    expect(
      shouldShowDiscoveryInvitationCard(
        recognizedDiscoveryInvitation: true,
        registrationCode: 'DISCOVERY',
        resolution: rejected,
        validationFailed: true,
      ),
      isFalse,
    );
    expect(
      shouldShowRegistrationPromoCodePanel(
        recognizedDiscoveryInvitation: true,
        registrationCode: 'DISCOVERY',
        validationFailed: true,
      ),
      isTrue,
    );
  });

  test('unavailable linked invitation recovers inline on the same form', () {
    expect(
      shouldRecoverUnavailableInvitationOnRegistrationForm('/register'),
      isTrue,
    );
    expect(
      shouldShowRegistrationPromoCodePanel(
        recognizedDiscoveryInvitation: false,
        registrationCode: null,
        validationFailed: false,
      ),
      isTrue,
    );
    expect(unavailableInvitationRecoveryMessage, contains('details are safe'));
    expect(
      unavailableInvitationRecoveryMessage,
      contains('another promo or invitation code'),
    );
  });
}
