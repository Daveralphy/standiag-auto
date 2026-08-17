// Sends one-time password codes by email via EmailJS — the one place in
// this app that talks to a third-party service directly from the client,
// since the Spark plan has no Cloud Functions to do this server-side.
// See EmailJsConfig for setup.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/emailjs_config.dart';

class OtpEmailService {
  OtpEmailService._();

  static Future<void> sendCode({
    required String toEmail,
    required String code,
  }) async {
    if (!EmailJsConfig.isConfigured) {
      throw StateError('emailjs-not-configured');
    }
    final response = await http
        .post(
          Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'service_id': EmailJsConfig.serviceId,
            'template_id': EmailJsConfig.templateId,
            'user_id': EmailJsConfig.publicKey,
            'template_params': {
              'to_email': toEmail,
              'otp_code': code,
            },
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw StateError('emailjs-send-failed');
    }
  }
}
