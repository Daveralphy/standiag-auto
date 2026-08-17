// Cloudinary stores every profile and vehicle photo for StanDiag Auto —
// Firebase Storage needs the paid Blaze plan just to be enabled at all,
// while Cloudinary's free tier (25GB storage + 25GB/month bandwidth) covers
// this comfortably with no credit card. Firebase itself still handles auth
// and Firestore; only image storage moved.
//
// Two separate unsigned upload presets — one per photo type — rather than
// one shared preset. Cloudinary requires *some* secret-free way for a
// mobile client to upload without a backend (Cloud Functions would need
// the same paid Blaze plan we're avoiding), and the security tradeoff of
// "unsigned" is that anyone holding the cloud name + preset name (both
// extractable from the shipped app) can trigger an upload through it. The
// mitigation, done entirely in each preset's Cloudinary dashboard config
// (not in this app), is to give each preset a *fixed* destination folder —
// Cloudinary always uses the preset's own folder over whatever folder the
// request asks for, so the worst an outside caller can do is add more
// files to profile_photos/ or vehicle_photos/, never write anywhere else,
// overwrite an existing file (Cloudinary forces overwrite=false for every
// unsigned upload, unconditionally), or touch Firestore — a photo's URL
// only ever reaches a real user's profile once written by *that signed-in
// user*, which is Firestore's security rules' job, unrelated to Cloudinary.
// See .env.example for the exact preset settings to configure.
//
// Until every value is set, CloudinaryService throws a clear "not
// configured" error before ever touching the picked image, instead of
// failing with a confusing HTTP error partway through an upload.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryConfig {
  CloudinaryConfig._();

  static String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get profilePhotoPreset =>
      dotenv.env['CLOUDINARY_PROFILE_UPLOAD_PRESET'] ?? '';
  static String get vehiclePhotoPreset =>
      dotenv.env['CLOUDINARY_VEHICLE_UPLOAD_PRESET'] ?? '';

  static bool get isConfigured =>
      cloudName.isNotEmpty &&
      profilePhotoPreset.isNotEmpty &&
      vehiclePhotoPreset.isNotEmpty;
}
