import "package:my_game_server/src/generated/endpoints.dart";
import "package:my_game_server/src/generated/protocol.dart";
import "package:serverpod/serverpod.dart";
import "package:serverpod_auth_idp_server/core.dart";
import "package:serverpod_auth_idp_server/providers/email.dart";

Future<void> run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints())
    ..initializeAuthServices(
      tokenManagerBuilders: [JwtConfigFromPasswords()],
      identityProviderBuilders: [
        EmailIdpConfigFromPasswords(
          sendRegistrationVerificationCode: _sendRegistrationCode,
          sendPasswordResetVerificationCode: _sendPasswordResetCode,
        ),
      ],
    );
  await pod.start();
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  session.log("[EmailIdp] Password reset code ($email): $verificationCode");
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  session.log("[EmailIdp] Registration code ($email): $verificationCode");
}
