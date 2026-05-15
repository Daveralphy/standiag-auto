import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle_model.dart';
import '../models/mechanic_model.dart';
import '../models/scan_model.dart';
import '../models/booking_model.dart';
import '../models/subscription_model.dart';
import 'dart:math';

class HomeService {
  final _db = Supabase.instance.client;

  String get _uid => _db.auth.currentUser!.id;

  // ── Car Owner ──────────────────────────────────────────────────

  Future<VehicleModel?> getActiveVehicle() async {
    final res = await _db
        .from('vehicles')
        .select()
        .eq('user_id', _uid)
        .eq('is_active', true)
        .maybeSingle();
    return res != null ? VehicleModel.fromMap(res) : null;
  }

  Future<Map<String, dynamic>> getVehicleStats(String vehicleId) async {
    final scans = await _db
        .from('scans')
        .select()
        .eq('vehicle_id', vehicleId)
        .order('scanned_at', ascending: false);
    final total = scans.length;
    final faultCodes = scans.isNotEmpty
        ? (scans.first['dtc_codes'] as List).length
        : 0;
    final lastScan = scans.isNotEmpty
        ? DateTime.parse(scans.first['scanned_at'] as String)
        : null;
    return {
      'total_scans': total,
      'fault_codes': faultCodes,
      'last_scan': lastScan,
      'severity': scans.isNotEmpty ? scans.first['severity'] : 'clear',
    };
  }

  Future<List<ScanModel>> getRecentScans({int limit = 5}) async {
    final res = await _db
        .from('scans')
        .select()
        .eq('user_id', _uid)
        .order('scanned_at', ascending: false)
        .limit(limit);
    return res.map((e) => ScanModel.fromMap(e)).toList();
  }

  Future<List<MechanicModel>> getNearbyMechanics({
    required double userLat,
    required double userLng,
    double radiusKm = 20,
    int limit = 10,
  }) async {
    final res = await _db
        .from('mechanic_profiles')
        .select('*, profiles(first_name, last_name, avatar_url)')
        .not('latitude', 'is', null)
        .not('longitude', 'is', null)
        .limit(50);

    final mechanics = res
        .map((e) {
          final lat = (e['latitude'] as num?)?.toDouble();
          final lng = (e['longitude'] as num?)?.toDouble();
          double? dist;
          if (lat != null && lng != null) {
            dist = _haversine(userLat, userLng, lat, lng);
          }
          return MechanicModel.fromMap({...e, 'distance_km': dist});
        })
        .where((m) =>
            m.distanceKm != null && m.distanceKm! <= radiusKm)
        .toList()
      ..sort((a, b) =>
          (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));

    // Increment views handled separately on profile open
    return mechanics.take(limit).toList();
  }

  Future<List<BookingModel>> getUserBookings({String? status}) async {
    var query = _db
        .from('bookings')
        .select('''
          *,
          user:profiles!user_id(first_name, last_name, avatar_url),
          mechanic:profiles!mechanic_id(first_name, last_name),
          vehicle:vehicles(make, model, year)
        ''')
        .eq('user_id', _uid);
    if (status != null) query = query.eq('status', status);
    final res = await query.order('created_at', ascending: false);
    return res.map((e) => BookingModel.fromMap(e)).toList();
  }

  Future<BookingModel> createBooking({
    required String mechanicId,
    required String vehicleId,
  }) async {
    final res = await _db.from('bookings').insert({
      'user_id': _uid,
      'mechanic_id': mechanicId,
      'vehicle_id': vehicleId,
      'status': 'pending',
    }).select('''
      *,
      user:profiles!user_id(first_name, last_name, avatar_url),
      mechanic:profiles!mechanic_id(first_name, last_name),
      vehicle:vehicles(make, model, year)
    ''').single();
    return BookingModel.fromMap(res);
  }

  // ── Mechanic ───────────────────────────────────────────────────

  Future<SubscriptionModel?> getActiveSubscription() async {
    final res = await _db
        .from('subscriptions')
        .select()
        .eq('mechanic_id', _uid)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .maybeSingle();
    return res != null ? SubscriptionModel.fromMap(res) : null;
  }

  Future<List<BookingModel>> getMechanicBookings({String? status}) async {
    var query = _db
        .from('bookings')
        .select('''
          *,
          user:profiles!user_id(first_name, last_name, avatar_url),
          mechanic:profiles!mechanic_id(first_name, last_name),
          vehicle:vehicles(make, model, year)
        ''')
        .eq('mechanic_id', _uid);
    if (status != null) query = query.eq('status', status);
    final res = await query.order('created_at', ascending: false);
    return res.map((e) => BookingModel.fromMap(e)).toList();
  }

  Future<void> acceptBooking(String bookingId) async {
    await _db.from('bookings').update({
      'status': 'accepted',
      'accepted_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  Future<void> declineBooking(String bookingId) async {
    await _db
        .from('bookings')
        .update({'status': 'declined'}).eq('id', bookingId);
  }

  Future<void> completeBooking(String bookingId) async {
    await _db.from('bookings').update({
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  Future<Map<String, dynamic>> getMechanicStats() async {
    final profile = await _db
        .from('mechanic_profiles')
        .select('rating, review_count, profile_views')
        .eq('id', _uid)
        .single();

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final completed = await _db
        .from('bookings')
        .select('id')
        .eq('mechanic_id', _uid)
        .eq('status', 'completed')
        .gte('completed_at', startOfMonth.toIso8601String());

    return {
      'rating': (profile['rating'] as num?)?.toDouble() ?? 0.0,
      'review_count': profile['review_count'] as int? ?? 0,
      'profile_views': profile['profile_views'] as int? ?? 0,
      'jobs_this_month': completed.length,
    };
  }

  Future<void> incrementProfileViews(String mechanicId) async {
    await _db.rpc('increment_profile_views',
        params: {'mechanic_uuid': mechanicId});
  }

  // ── Helpers ────────────────────────────────────────────────────

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}