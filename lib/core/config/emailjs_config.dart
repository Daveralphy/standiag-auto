// EmailJS lets a client-only app (no backend) send real email through a
// relay service instead of embedding SMTP credentials. This app runs on
// Firebase's free Spark plan, which has no Cloud Functions, so this is the
// path used to actually deliver the password-change OTP code by email.
//
// The three values below live in .env (gitignored, never committed) rather
// than here, so swapping to a different owner's EmailJS account never
// touches a tracked file. See .env.example for the full setup steps:
// 1. Create a free account at https://www.emailjs.com
// 2. Email Services -> Add New Service (e.g. connect Gmail) -> its Service
//    ID goes in EMAILJS_SERVICE_ID.
// 3. Email Templates -> Create New Template with two variables used in the
//    template body/subject: {{to_email}} and {{otp_code}} -> its Template
//    ID goes in EMAILJS_TEMPLATE_ID.
// 4. Account -> General -> your Public Key goes in EMAILJS_PUBLIC_KEY.
//
// Until all three are set, OtpEmailService throws a clear "not configured"
// error instead of silently failing.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailJsConfig {
  EmailJsConfig._();

  static String get serviceId => dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  static String get templateId => dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  static String get publicKey => dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';

  static bool get isConfigured =>
      serviceId.isNotEmpty && templateId.isNotEmpty && publicKey.isNotEmpty;
}
