// Uploads images to Cloudinary via an "unsigned" upload preset — the app
// posts the file straight from the phone with just a public cloud name and
// preset name (both in .env, see CloudinaryConfig), no API secret and no
// backend involved. See CloudinaryConfig's own comment for the security
// model this relies on (a fixed folder per preset, configured in Cloudinary's
// dashboard, not here) and why Cloudinary replaced Firebase Storage.
//
// Deleting an old photo is different — that needs a *signed* request (an
// API secret an app can never safely hold), so it goes through the
// deleteCloudinaryImage Cloud Function instead of Cloudinary directly. See
// functions/src/index.ts for that side.

import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';

class CloudinaryUploadException implements Exception {
  final String message;
  const CloudinaryUploadException(this.message);

  @override
  String toString() => message;
}

/// Matches the 5MB cap storage.rules used to enforce for Firebase Storage.
/// This is a UX nicety, not a security boundary — it only ever runs for
/// legitimate calls through this app's own code, so it can't stop a
/// malicious caller hitting Cloudinary's API directly with the preset name.
/// That protection lives entirely in each preset's dashboard config.
const int _maxImageBytes = 5 * 1024 * 1024;

class CloudinaryService {
  CloudinaryService._();

  /// Uploads [file] through [preset] and returns its permanent, public
  /// "secure_url". Each call produces a new file — unsigned uploads can
  /// never overwrite an existing one (Cloudinary enforces this itself), so
  /// an old photo is simply orphaned, not deleted, once its Firestore field
  /// is replaced with a new URL.
  ///
  /// [ownerId] (and, for a vehicle photo, [vehicleId]) get baked into the
  /// upload as a readable public_id prefix, a tag, and context metadata —
  /// all plain unsigned-upload parameters, no API secret needed. The
  /// public_id specifically ("{ownerId}_{timestamp}") is what
  /// [deleteImage]/deleteCloudinaryImage checks ownership against later, and
  /// what makes every upload findable by hand too — search `tag:user_{uid}`
  /// (or `tag:vehicle_{id}`) in Cloudinary's dashboard for everything a
  /// given user/vehicle has ever uploaded.
  static Future<String> uploadImage(
    File file, {
    required String preset,
    required String ownerId,
    String? vehicleId,
  }) async {
    if (!CloudinaryConfig.isConfigured) {
      throw const CloudinaryUploadException(
        'Image storage isn\'t configured. Set CLOUDINARY_CLOUD_NAME, '
        'CLOUDINARY_PROFILE_UPLOAD_PRESET and CLOUDINARY_VEHICLE_UPLOAD_PRESET '
        'in .env — see .env.example.',
      );
    }

    final size = await file.length();
    if (size > _maxImageBytes) {
      throw const CloudinaryUploadException(
        'That image is too large — please choose one under 5MB.',
      );
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tags = [
      'user_$ownerId',
      if (vehicleId != null) 'vehicle_$vehicleId',
    ].join(',');
    final context = [
      'ownerId=$ownerId',
      if (vehicleId != null) 'vehicleId=$vehicleId',
    ].join('|');

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = preset
      ..fields['public_id'] = '${ownerId}_$timestamp'
      ..fields['tags'] = tags
      ..fields['context'] = context
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw CloudinaryUploadException(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final url = decoded is Map<String, dynamic>
        ? decoded['secure_url'] as String?
        : null;
    if (url == null) {
      throw const CloudinaryUploadException(
        'Cloudinary\'s upload response had no image URL.',
      );
    }
    return url;
  }

  /// Deletes the Cloudinary image at [url] via the deleteCloudinaryImage
  /// Cloud Function — best-effort: swallows any failure (not signed in,
  /// function unreachable, [url] predates the Cloudinary migration and isn't
  /// one of ours, etc.) rather than throwing, since a failed cleanup call
  /// should never block or fail the "your photo was updated" flow a caller
  /// is actually waiting on. Call this *after* the new photo's URL is
  /// already saved — never before, in case the save itself fails.
  static Future<void> deleteImage(String url) async {
    final publicId = _publicIdFromUrl(url);
    if (publicId == null) return;
    try {
      await FirebaseFunctions.instance
          .httpsCallable('deleteCloudinaryImage')
          .call({'publicId': publicId});
    } catch (_) {
      // Worst case: one orphaned photo sits in Cloudinary until a manual
      // dashboard cleanup — never worth surfacing to the user.
    }
  }

  /// Extracts "{ownerId}_{timestamp}" from one of this app's own Cloudinary
  /// URLs — the last path segment, minus its file extension. Returns null
  /// for anything that doesn't look like a Cloudinary URL at all (e.g. an
  /// old Firebase Storage URL from before this app migrated), so
  /// [deleteImage] never even attempts to delete something it didn't create.
  static String? _publicIdFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.host.contains('cloudinary.com') ||
        uri.pathSegments.isEmpty) {
      return null;
    }
    final lastSegment = uri.pathSegments.last;
    final dotIndex = lastSegment.lastIndexOf('.');
    return dotIndex > 0 ? lastSegment.substring(0, dotIndex) : lastSegment;
  }
}
