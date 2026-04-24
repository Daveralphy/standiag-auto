import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  final _supabase = Supabase.instance.client;

  Future<void> addVehicle({
    required String make,
    required String model,
    required String year,
    required String engineType,
    String? nickname,
    String? vin,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final duplicate = await _supabase
        .from('vehicles')
        .select('id')
        .eq('user_id', userId)
        .eq('make', make)
        .eq('model', model)
        .eq('year', year);

    if ((duplicate as List).isNotEmpty) {
      throw Exception('You already have a $make $model $year added.');
    }

    final all = await _supabase
        .from('vehicles')
        .select('id')
        .eq('user_id', userId);

    final isFirst = (all as List).isEmpty;

    await _supabase.from('vehicles').insert({
      'user_id': userId,
      'make': make,
      'model': model,
      'year': year,
      'engine_type': engineType,
      'nickname': nickname?.isNotEmpty == true ? nickname : null,
      'vin': vin?.isNotEmpty == true ? vin : null,
      'is_active': isFirst,
    });
  }

  Future<List<Map<String, dynamic>>> getUserVehicles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('vehicles')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getActiveVehicle() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('vehicles')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();

    return response;
  }

  Future<bool> hasVehicles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('vehicles')
        .select('id')
        .eq('user_id', userId)
        .limit(1);

    return (response as List).isNotEmpty;
  }

  Future<void> setActiveVehicle(String vehicleId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('vehicles')
        .update({'is_active': false})
        .eq('user_id', userId);

    await _supabase
        .from('vehicles')
        .update({'is_active': true})
        .eq('id', vehicleId);
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final vehicle = await _supabase
        .from('vehicles')
        .select('is_active')
        .eq('id', vehicleId)
        .maybeSingle();

    await _supabase
        .from('vehicles')
        .delete()
        .eq('id', vehicleId);

    if (vehicle != null && vehicle['is_active'] == true) {
      final remaining = await _supabase
          .from('vehicles')
          .select('id')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);

      if ((remaining as List).isNotEmpty) {
        await _supabase
            .from('vehicles')
            .update({'is_active': true})
            .eq('id', remaining[0]['id']);
      }
    }
  }

  Future<Map<String, dynamic>?> getVehicleById(String vehicleId) async {
    final response = await _supabase
        .from('vehicles')
        .select()
        .eq('id', vehicleId)
        .maybeSingle();
    return response;
  }
}
